#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")"
if [[ ! -d .venv ]]; then
  python3 -m venv .venv
fi
source .venv/bin/activate
python -m pip install -q --upgrade pip
python -m pip install -q -r requirements.txt
python generate_news.py
