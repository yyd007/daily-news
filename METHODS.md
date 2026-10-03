# Methods, Tech, and Tools

This file lists the methods, technologies, and tools used to build the daily news briefing.

## Purpose

The project fetches the day's top stories in three buckets, then writes one Word document:

1. Top 10 worldwide
2. Top 10 in China
3. Top 10 related to AI

The briefing is always written to `Daily News.docx` and overwritten on each run. The date is shown inside the document. A macOS Launch Agent runs the job every day at 9:00 AM.

## Runtime and language

| Item | Detail |
| --- | --- |
| Language | Python 3 |
| Tested interpreter | Python 3.14 from Homebrew (`/opt/homebrew/bin/python3`) |
| Isolation | `python3 -m venv .venv` |
| Package installer | `pip` |
| Shell | `zsh` |
| OS | macOS (darwin), scheduled with LaunchAgents |

## Python packages

Pinned in `requirements.txt`:

| Package | Version | Role |
| --- | --- | --- |
| `requests` | 2.32.5 | HTTP fetch of RSS feeds with a browser-like User-Agent |
| `feedparser` | 6.0.12 | Parse RSS/Atom into feed and entry objects |
| `lxml` | 6.0.2 | Read HTML inside Google News summaries and pull real article links |
| `python-docx` | 1.2.0 | Build and save the `.docx` briefing |

## Python standard library

| Module | Role |
| --- | --- |
| `html` | Unescape HTML entities in titles and summaries |
| `re` | Strip tags, clean source names, normalize titles for dedupe |
| `sys` | Print skipped-feed errors to stderr |
| `datetime` | Generation timestamp and published times |
| `email.utils.parsedate_to_datetime` | Parse RSS `published` / `updated` date strings |
| `pathlib.Path` | Resolve the project folder and output path |
| `urllib.parse` | Read hosts and `url=` query values from Google News links |
| `zoneinfo.ZoneInfo` | Convert times to `Asia/Shanghai` |

## News sources

No paid news API is used. Headlines come from public RSS feeds.

### Worldwide

1. Google News World topic RSS
2. BBC World RSS
3. Google News top stories RSS (fallback)

### China

1. Google News China (zh-CN)
2. Google News search for `??` in the last day
3. BBC Chinese (simplified) RSS
4. Google News English search for `China` in the last day (fallback)

### AI

1. Google News search for `artificial intelligence`, `generative AI`, `ChatGPT`, `OpenAI`, `LLM`
2. Google News Chinese search for `????` / `???`
3. The Verge AI RSS

Feeds are tried in order. The first 10 unique headlines in a section are kept. If one feed fails (timeout, HTTP 400), the next feed is used.

## Methods in `generate_news.py`

### `fetch_feed(url)`

Downloads one RSS URL with `requests.get`. A Chrome-like User-Agent is sent because some publishers block the default Python client. The response body is parsed with `feedparser`. Each entry becomes a dict: title, link, source, published time, summary.

### `clean_text(value)` / `clean_summary(value)`

Removes HTML tags, unescapes entities, and collapses whitespace. Summaries are truncated to about 280 characters. Google News "View Full Coverage" boilerplate is removed.

### `extract_source(entry, title, feed_title, link)`

Resolves the outlet for each story, in this order:

1. RSS `<source>` title from Google News
2. Trailing ` - Outlet` text in the headline
3. Feed title, if it is not a generic Google News label
4. Domain lookup from `DOMAIN_SOURCES` (BBC, Reuters, Xinhua, The Verge, and others)

Generic labels such as `Google News` are discarded.

### `unwrap_link(entry)`

Prefers a publisher URL over a Google News redirect:

1. Scan HTML in the summary for the first non-Google `href`
2. Else read `?url=` from a Google News link
3. Else keep the original RSS link

### `parse_published(entry)`

Parses RSS dates and converts them to Asia/Shanghai.

### `normalize_title(title)` / `collect_top10(feeds)`

Builds a fingerprint from letters, digits, and CJK characters. Near-duplicate headlines are skipped. Collection stops at 10 stories per section.

### `write_document(sections, generated_at)`

Creates the Word file with `python-docx`:

- Header: `Daily News | YYYY-MM-DD HH:MM`
- Title and weekday date
- Three numbered sections
- Each item: headline, source, date, summary, clickable link
- English headlines and summaries get a Chinese translation underneath via the Google Translate public endpoint
- Fonts: Calibri for Latin text, PingFang SC for Chinese (`w:eastAsia`)
- Low-level OOXML for a teal rule and hyperlinks
- Output name: `Daily News.docx` (overwritten every run; older dated copies are removed)

### `write_html(sections, generated_at)`

Writes the same three lists to `site/index.html`: newspaper layout, Chinese translations under English headlines, and GitHub Pages hosting.

## Scheduling and shell tools

| Tool | Role |
| --- | --- |
| `run.sh` | Create/activate the venv, install deps, run `generate_news.py` |
| `install_schedule.sh` | Write `~/Library/LaunchAgents/com.aria.dailynews.plist` and load it |
| `uninstall_schedule.sh` | Unload and remove that Launch Agent |
| `launchctl bootstrap` / `bootout` | Modern macOS load/unload |
| `launchctl load` / `unload` | Fallback on older macOS |
| `StartCalendarInterval` | Fire at 09:00 local time every day |
| Project `logs/` | stdout/stderr from the scheduled run |

## Document and file conventions

| Item | Detail |
| --- | --- |
| Output format | Word `.docx` plus `site/index.html` |
| Filename | Always `Daily News.docx` and `site/index.html`; both overwritten |
| Hosting | GitHub Pages at https://yyd007.github.io/daily-news/ |
| Timezone | Asia/Shanghai |
| Generated files | Word files, `.venv/`, and `logs/` are gitignored |

## Version control and GitHub

| Tool | Role |
| --- | --- |
| Git | Local repo in this folder, branch `main` |
| GitHub | Remote `git@github.com:yyd007/daily-news.git` |
| SSH | Push/auth as GitHub user `yyd007` |
| GitHub REST API | Used to create the repository and enable Pages |
| GitHub Actions | Daily rebuild at 01:00 UTC (09:00 Asia/Shanghai) and Pages deploy |

## What was intentionally not used

- No NewsAPI or other key-based news API
- No database
- No LLM for summarization; summaries come from the RSS entries
