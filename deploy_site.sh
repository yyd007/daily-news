#!/bin/zsh
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
cd "$(dirname "$0")"

if [[ ! -f site/index.html ]]; then
  echo "No website to publish."
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repo; skip website publish."
  exit 0
fi

git add site/index.html
if git diff --cached --quiet; then
  echo "Website unchanged."
  exit 0
fi

git commit -m "$(cat <<'EOF'
Update daily news website.

EOF
)"
git push origin HEAD
echo "Published https://yyd007.github.io/daily-news/"
