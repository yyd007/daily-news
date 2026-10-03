"""Render the daily news briefing as a static webpage."""

from __future__ import annotations

from datetime import datetime
from html import escape
from pathlib import Path


def esc(value: str) -> str:
    return escape(value or "", quote=True)


def render_site(
    sections: dict[str, list[dict]],
    generated_at: datetime,
    output_dir: Path,
    section_specs: list[dict],
    format_when,
) -> Path:
    date_en = generated_at.strftime("%A, %B %-d, %Y")
    date_iso = generated_at.strftime("%Y-%m-%d")
    date_zh = (
        generated_at.strftime("%Y")
        + "\u5e74"
        + generated_at.strftime("%-m")
        + "\u6708"
        + generated_at.strftime("%-d")
        + "\u65e5"
    )
    weekday_zh = [
        "\u661f\u671f\u4e00",
        "\u661f\u671f\u4e8c",
        "\u661f\u671f\u4e09",
        "\u661f\u671f\u56db",
        "\u661f\u671f\u4e94",
        "\u661f\u671f\u516d",
        "\u661f\u671f\u65e5",
    ]
    weekday = weekday_zh[generated_at.weekday()]
    empty_label = "\u4eca\u5929\u8fd9\u4e00\u680f\u6682\u65f6\u6ca1\u6709\u6293\u5230\u65b0\u95fb\u3002"

    columns = []
    for spec in section_specs:
        stories = sections[spec["key"]]
        items = []
        if not stories:
            items.append(f'<p class="empty">{esc(empty_label)}</p>')
        for index, story in enumerate(stories, start=1):
            source = story["source"] or "Unknown source"
            href = story["link"] or "#"
            zh = story.get("title_zh") or ""
            zh_html = f'<p class="zh">{esc(zh)}</p>' if zh else ""
            items.append(
                "<article class=\"story\">"
                f"<div class=\"story-index\">{index:02d}</div>"
                "<div class=\"story-body\">"
                f"<h3><a href=\"{esc(href)}\" target=\"_blank\" rel=\"noopener noreferrer\">{esc(story['title'])}</a></h3>"
                f"{zh_html}"
                f"<p class=\"meta\"><span>{esc(source)}</span>{esc(format_when(story['published']))}</p>"
                "</div></article>"
            )
        columns.append(
            f"<section class=\"column\" id=\"{esc(spec['key'])}\">"
            "<header class=\"column-head\">"
            f"<p class=\"eyebrow\">{esc(spec['title_zh'])}</p>"
            f"<h2>{esc(spec['title'])}</h2>"
            "</header>"
            f"{''.join(items)}"
            "</section>"
        )

    page = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Daily News | DATE_ISO</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@500;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,700&display=swap" rel="stylesheet">
  <style>
    :root { --paper:#f4ead7; --ink:#1b1612; --red:#9f1d1d; --muted:#6d6256; }
    * { box-sizing: border-box; }
    html, body { margin: 0; padding: 0; }
    body { background: var(--paper); color: var(--ink); font-family: "Source Serif 4", "Noto Serif SC", "Songti SC", Georgia, serif; line-height: 1.45; }
    a { color: inherit; }
    .wrap { width: min(1180px, calc(100% - 32px)); margin: 0 auto; padding: 28px 0 64px; }
    .masthead { border-top: 8px solid var(--ink); border-bottom: 3px double var(--ink); padding: 18px 0 14px; text-align: center; }
    .kicker { margin: 0; letter-spacing: 0.28em; text-transform: uppercase; font-size: 12px; color: var(--red); }
    .brand { margin: 6px 0 2px; font-size: clamp(42px, 8vw, 78px); line-height: 0.9; letter-spacing: -0.04em; }
    .brand span { color: var(--red); }
    .dateline { margin: 10px 0 0; font-size: 15px; color: var(--muted); }
    nav { display: flex; justify-content: center; gap: 22px; padding: 12px 0 18px; border-bottom: 1px solid var(--ink); font-size: 14px; }
    nav a { text-decoration: none; }
    nav a:hover { color: var(--red); }
    .deck { display: grid; grid-template-columns: repeat(3, 1fr); gap: 28px; margin-top: 28px; }
    .column-head { border-bottom: 2px solid var(--ink); margin-bottom: 16px; padding-bottom: 8px; }
    .eyebrow { margin: 0; color: var(--red); letter-spacing: 0.16em; font-size: 12px; }
    .column-head h2 { margin: 4px 0 0; font-size: 26px; }
    .story { display: grid; grid-template-columns: 36px 1fr; gap: 10px; padding: 12px 0; border-bottom: 1px solid rgba(27, 22, 18, 0.14); }
    .story-index { font-size: 18px; font-weight: 700; color: var(--red); }
    .story h3 { margin: 0 0 6px; font-size: 18px; line-height: 1.28; }
    .story h3 a { text-decoration: none; }
    .story h3 a:hover { color: var(--red); }
    .zh { margin: 0 0 8px; color: #3f4d4a; font-size: 15px; }
    .meta { margin: 0; color: var(--muted); font-size: 12px; letter-spacing: 0.02em; }
    .meta span { margin-right: 10px; text-transform: uppercase; }
    .empty { color: var(--muted); font-style: italic; }
    footer { margin-top: 36px; padding-top: 14px; border-top: 2px solid var(--ink); color: var(--muted); font-size: 13px; text-align: center; }
    @media (max-width: 900px) { .deck { grid-template-columns: 1fr; } nav { flex-wrap: wrap; } }
  </style>
</head>
<body>
  <div class="wrap">
    <header class="masthead">
      <p class="kicker">Morning Briefing</p>
      <h1 class="brand">Daily <span>News</span></h1>
      <p class="dateline">DATE_EN | WEEKDAY DATE_ZH</p>
    </header>
    <nav>
      <a href="#worldwide">Worldwide</a>
      <a href="#china">China</a>
      <a href="#ai">AI</a>
    </nav>
    <main class="deck">COLUMNS</main>
    <footer>Automatically generated on DATE_ISO. Same briefing as Daily News.docx.</footer>
  </div>
</body>
</html>
"""
    page = (
        page.replace("DATE_ISO", esc(date_iso))
        .replace("DATE_EN", esc(date_en))
        .replace("WEEKDAY", esc(weekday))
        .replace("DATE_ZH", esc(date_zh))
        .replace("COLUMNS", "".join(columns))
    )
    site_dir = output_dir / "site"
    site_dir.mkdir(parents=True, exist_ok=True)
    html_path = site_dir / "index.html"
    html_path.write_text(page, encoding="utf-8")
    return html_path
