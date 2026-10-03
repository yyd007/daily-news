# Daily News

Generates a Word briefing with:

1. Top 10 worldwide
2. Top 10 in China
3. Top 10 related to AI

Each run overwrites two copies of the same briefing:

- `Daily News.docx` in this folder
- `site/index.html`, published at https://yyd007.github.io/daily-news/

See [METHODS.md](METHODS.md) for the methods, tech, and tools used.

## Run once

```bash
cd "/Users/aria/Downloads/daily news"
./run.sh
```

## Automatic daily run (9:00 AM)

This Mac writes `Daily News.docx` at 9:00 AM and also publishes the webpage.

The live site is also rebuilt every day at 9:00 AM Asia/Shanghai by GitHub Actions, even if this computer is off:

https://yyd007.github.io/daily-news/

```bash
./install_schedule.sh
```

To stop the local Mac job:

```bash
./uninstall_schedule.sh
```
