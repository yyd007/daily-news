# Methods, Tech, and Tools

This file lists the methods, technologies, and tools used to build the daily news briefing.

## Purpose

The project fetches the day's top stories in three buckets:

1. Top 10 worldwide
2. Top 10 in China
3. Top 10 related to AI

There are two editions each day:

- **9:00 AM** morning briefing
- **7:00 PM** evening briefing, added under the morning list

On the same date, the morning list is kept. The evening run only appends. When the date changes, yesterday is replaced and there is no evening block until 7:00 PM.

Outputs:

- `Daily News.docx` in this folder
- `site/index.html` at https://yyd007.github.io/daily-news/
- `site/briefing.json` so the evening run can reuse the morning list

Anyone with the webpage link can open it. No login is required.

## Runtime and language

| Item | Detail |
| --- | --- |
| Language | Python 3 |
| Tested interpreter | Python 3.14 from Homebrew (`/opt/homebrew/bin/python3`) |
| Isolation | `python3 -m venv .venv` |
| Package installer | `pip` |
| Shell | `zsh` |
| OS | macOS, scheduled with LaunchAgents |
| Website host | GitHub Pages |

## Python packages

Pinned in `requirements.txt`:

| Package | Version | Role |
| --- | --- | --- |
| `requests` | 2.32.5 | HTTP fetch of RSS feeds, plus translation requests |
| `feedparser` | 6.0.12 | Parse RSS/Atom into feed and entry objects |
| `lxml` | 6.0.2 | Read HTML in Google News summaries and recover article links |
| `python-docx` | 1.2.0 | Build and save the `.docx` briefing |

`web_page.py` builds the static HTML. No extra web framework is used.

## Python standard library

| Module | Role |
| --- | --- |
| `html` | Unescape HTML entities in titles and summaries |
| `json` | Save and reload `site/briefing.json` between 9:00 and 19:00 |
| `os` | Optional `DAILY_NEWS_EDITION=morning` or `evening` override |
| `re` | Strip tags, clean source names, normalize titles for dedupe |
| `sys` | Print skipped-feed errors to stderr |
| `datetime` | Generation time, published dates, morning vs evening cutoff |
| `email.utils.parsedate_to_datetime` | Parse RSS date strings |
| `pathlib.Path` | Project folder and output paths |
| `urllib.parse` | Hosts and `url=` values from Google News links |
| `zoneinfo.ZoneInfo` | All local times use `Asia/Shanghai` |

## News sources

No NewsAPI or other key-based news API is used. Headlines come from public **RSS** feeds.

RSS is a public XML list that many news sites publish: title, link, time, and a short summary. The script downloads those URLs and parses them. No account or API key is required.

### Worldwide

1. Google News World topic RSS
2. BBC World RSS
3. Google News top stories RSS (fallback)

### China

1. Google News China (zh-CN)
2. Google News search for China in Chinese, last day
3. BBC Chinese (simplified) RSS
4. Google News English search for `China`, last day (fallback)

### AI

1. Google News search for `artificial intelligence`, `generative AI`, `ChatGPT`, `OpenAI`, `LLM`
2. Google News Chinese search for AI / large-model terms
3. The Verge AI RSS

Feeds are tried in order. The first 10 unique headlines in a section are kept. If one feed fails, the next feed is used.

## Methods in `generate_news.py`

### `fetch_feed(url)`

Downloads one RSS URL with `requests.get`. A Chrome-like User-Agent is sent because some publishers block the default Python client. `feedparser` turns the XML into entries: title, link, source, published time, summary.

### `extract_source(...)`

Finds the real outlet, in this order:

1. RSS `<source>` title from Google News
2. Trailing ` - Outlet` text in the headline
3. Feed title, if it is not a generic Google News label
4. Domain lookup (`DOMAIN_SOURCES`)

### `unwrap_link(entry)`

Prefers a publisher URL over a Google News redirect.

### `collect_top10(feeds)`

Deduplicates headlines and stops at 10 stories per section.

### `translate_to_zh(text)`

English headlines get a Chinese line underneath. Translation uses public Google / MyMemory endpoints, not an LLM and not a paid Translate API key.

### `current_edition(now)` / `load_state` / `merge_edition` / `save_state`

- Before 19:00: morning edition
- From 19:00: evening edition
- Same date: keep morning, write or replace evening only
- New date: start empty, so evening is hidden until 7:00 PM
- State is stored in `site/briefing.json`

### `write_document(state, generated_at)`

Writes `Daily News.docx`:

- Date in the header (no clock time)
- Morning block first, then evening block if it exists
- Each item: headline, source, date, Chinese translation, link
- Fonts: Calibri plus PingFang SC for Chinese

### `write_html(state, generated_at)`

Calls `web_page.render_site` and writes `site/index.html`. Same two-edition layout as the Word file.

## Scheduling

**LaunchAgents** is built into macOS. The system service `launchd` reads `~/Library/LaunchAgents/com.aria.dailynews.plist` and runs `~/daily-news/run.sh` at 09:00 and 19:00.

The underlying restriction is from macOS, not from one script name. LaunchAgents cannot use a zsh/bash file as their program if that file is under `Downloads` / `Desktop` / `Documents`, or if the path contains a space. That is why `run.sh`, `source ./run.sh`, and `deploy_site.sh` all failed the same way. The scheduled checkout is therefore `~/daily-news` (no space, not in Downloads). `install_schedule.sh` rsyncs this project there. Logs go to `~/Library/Logs/daily-news/`.

**Cron** is the usual Linux/server timer (a time rule plus a command). This Mac job does not use cron. GitHub Actions uses a cron-style rule in UTC, set 8 minutes past the hour because GitHub often drops jobs scheduled at `:00`:

| Local time (Asia/Shanghai) | GitHub Actions cron (UTC) |
| --- | --- |
| 09:08 | `8 1 * * *` |
| 09:38 | `38 1 * * *` (backup) |
| 19:08 | `8 11 * * *` |
| 19:38 | `38 11 * * *` (backup) |

| Tool | Role |
| --- | --- |
| `run.sh` | Create/activate the venv, install deps, generate, publish site |
| `publish_site.py` | Commit `site/index.html` and `site/briefing.json`, then push |
| `deploy_site.sh` | Thin wrapper around `publish_site.py` for a manual run |
| `install_schedule.sh` | Install the 9:00 and 19:00 Launch Agent |
| `uninstall_schedule.sh` | Remove that Launch Agent |
| `launchctl bootstrap` / `bootout` | Load/unload the agent on current macOS |
| GitHub Actions | Rebuild and publish the website at 9:08 and 19:08 even if this Mac is off |
| GitHub Pages | Public host: https://yyd007.github.io/daily-news/ |

## Document and file conventions

| Item | Detail |
| --- | --- |
| Word file | Always `Daily News.docx` |
| Webpage | Always `site/index.html` |
| Same day | Morning stays; 7:00 PM is appended below |
| New day | File and page are replaced; no evening block before 19:00 |
| Timezone | Asia/Shanghai |
| Gitignore | `.venv/`, `logs/`, `*.docx` |

## Version control and GitHub

| Tool | Role |
| --- | --- |
| Git | Local repo, branch `main` |
| GitHub | `git@github.com:yyd007/daily-news.git` (public) |
| SSH | Push as `yyd007` |
| GitHub Pages | Public webpage, no login needed to read |

## What was intentionally not used

- No NewsAPI or other key-based news API. Information is read from public RSS feeds.
- No database. Same-day morning/evening state is a JSON file.
- No cron on this Mac. The Mac timer is LaunchAgents. GitHub Actions uses a cron-style UTC schedule.
- No LLM for summarization. Short text comes from RSS; Chinese lines are machine translation of headlines.
