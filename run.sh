#!/bin/zsh
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

RUNTIME="$HOME/daily-news"
HERE="$(cd "$(dirname "$0")" && pwd -P)"
if [[ "$HERE" != "$RUNTIME" && -x "$RUNTIME/run.sh" ]]; then
  echo "Redirecting scheduled run to $RUNTIME"
  cd "$RUNTIME"
  exec /bin/zsh "$RUNTIME/run.sh"
fi

cd "$HERE"
echo "daily-news start $(date) pwd=$PWD script=$0"

if [[ ! -d .venv ]]; then
  python3 -m venv .venv
fi
source .venv/bin/activate
python -m pip install -q --upgrade pip
python -m pip install -q -r requirements.txt
python generate_news.py
python publish_site.py
echo "daily-news done $(date)"
