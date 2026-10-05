#!/bin/zsh
set -euo pipefail

# macOS LaunchAgents cannot execute zsh/bash scripts from Downloads,
# Desktop, Documents, or any path with a space. The scheduled job always
# runs from $HOME/daily-news.

LABEL="com.aria.dailynews"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
OLD_WRAPPER="$HOME/Library/LaunchAgents/${LABEL}.run.sh"
LOG_DIR="$HOME/Library/Logs/daily-news"
RUNTIME="$HOME/daily-news"
SRC="$(cd "$(dirname "$0")" && pwd -P)"
mkdir -p "$LOG_DIR" "$RUNTIME"

if [[ "$SRC" != "$RUNTIME" ]]; then
  /usr/bin/rsync -a --delete \
    --exclude .venv \
    --exclude logs \
    --exclude __pycache__ \
    --exclude .DS_Store \
    "$SRC/" "$RUNTIME/"
fi

rm -f "$OLD_WRAPPER"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>${RUNTIME}/run.sh</string>
  </array>
  <key>StartCalendarInterval</key>
  <array>
    <dict>
      <key>Hour</key>
      <integer>9</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <dict>
      <key>Hour</key>
      <integer>19</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
  </array>
  <key>WorkingDirectory</key>
  <string>${RUNTIME}</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>
  <key>StandardOutPath</key>
  <string>${LOG_DIR}/daily-news.out.log</string>
  <key>StandardErrorPath</key>
  <string>${LOG_DIR}/daily-news.err.log</string>
  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
EOF

UID_NUM="$(id -u)"
launchctl bootout "gui/${UID_NUM}" "$PLIST" >/dev/null 2>&1 || true
launchctl bootout "gui/${UID_NUM}/${LABEL}" >/dev/null 2>&1 || true
launchctl unload "$PLIST" >/dev/null 2>&1 || true
if ! launchctl bootstrap "gui/${UID_NUM}" "$PLIST" >/dev/null 2>&1; then
  launchctl load "$PLIST"
fi

echo "Scheduled daily news for 9:00 AM and 7:00 PM."
echo "Runtime: $RUNTIME"
echo "Plist: $PLIST"
echo "Logs: $LOG_DIR"
