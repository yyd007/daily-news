# Daily News

Generates a Word briefing with:

1. Top 10 worldwide
2. Top 10 in China
3. Top 10 related to AI

The document is written into this folder. The filename includes the date and time, for example `Daily News 2026-10-04 09-00.docx`.

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
