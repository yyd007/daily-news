#!/bin/zsh
set -euo pipefail

LABEL="com.aria.dailynews"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
PROJECT="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$PROJECT/logs"
mkdir -p "$LOG_DIR"

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
    <string>${PROJECT}/run.sh</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>9</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>WorkingDirectory</key>
  <string>${PROJECT}</string>
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
launchctl unload "$PLIST" >/dev/null 2>&1 || true
if ! launchctl bootstrap "gui/${UID_NUM}" "$PLIST" >/dev/null 2>&1; then
  launchctl load "$PLIST"
fi
echo "Scheduled daily news for 9:00 AM."
echo "Plist: $PLIST"
