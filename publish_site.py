#!/usr/bin/env python3
"""Commit and push the generated website."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SITE_FILES = ["site/index.html", "site/briefing.json"]


def run(args: list[str], check: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        cwd=ROOT,
        check=check,
        text=True,
        capture_output=True,
    )


def main() -> int:
    if not (ROOT / "site/index.html").is_file():
        print("No website to publish.")
        return 0
    if run(["git", "rev-parse", "--is-inside-work-tree"]).returncode != 0:
        print("Not a git repo; skip website publish.")
        return 0

    run(["git", "pull", "--rebase", "origin", "HEAD"])
    run(["git", "add", *SITE_FILES], check=True)
    if run(["git", "diff", "--cached", "--quiet"]).returncode == 0:
        print("Website unchanged.")
        return 0

    commit = run(["git", "commit", "-m", "Update daily news website."])
    if commit.returncode != 0:
        sys.stderr.write(commit.stderr)
        return commit.returncode
    push = run(["git", "push", "origin", "HEAD"])
    if push.returncode != 0:
        sys.stderr.write(push.stderr)
        return push.returncode
    print("Published https://yyd007.github.io/daily-news/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
