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

```bash
./install_schedule.sh
```

To stop the daily job:

```bash
./uninstall_schedule.sh
```
