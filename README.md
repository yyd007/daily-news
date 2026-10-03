# Daily News

Generates a Word briefing and webpage with:

1. Top 10 worldwide
2. Top 10 in China
3. Top 10 related to AI

There are two editions each day:

- 9:00 AM morning briefing
- 7:00 PM evening briefing, added under the morning list

The same date keeps both editions. A new date replaces yesterday's file.

Outputs:

- `Daily News.docx` in this folder
- `site/index.html`, published at https://yyd007.github.io/daily-news/

See [METHODS.md](METHODS.md) for the methods, tech, and tools used.

## Run once

```bash
cd "/Users/aria/Downloads/daily news"
./run.sh
```

## Automatic daily run (9:00 AM and 7:00 PM)

This Mac writes the Word file and publishes the webpage at 9:00 AM and 7:00 PM.

GitHub Actions also rebuilds the site at those times, even if this computer is off:

https://yyd007.github.io/daily-news/

```bash
./install_schedule.sh
```

To stop the local Mac job:

```bash
./uninstall_schedule.sh
```
