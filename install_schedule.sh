#!/bin/zsh
set -euo pipefail

LABEL="com.aria.dailynews"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
WRAPPER="$HOME/Library/LaunchAgents/${LABEL}.run.sh"
LOG_DIR="$HOME/Library/Logs/daily-news"
PROJECT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$LOG_DIR"

cat > "$WRAPPER" <<EOF
#!/bin/zsh
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:\$PATH"
cd $(printf '%q' "$PROJECT")
source ./run.sh
EOF
chmod +x "$WRAPPER"

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
    <string>${WRAPPER}</string>
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
  <string>${HOME}/Library/LaunchAgents</string>
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
launchctl unload "$PLIST" >/dev/null 2>&1 || true
if ! launchctl bootstrap "gui/${UID_NUM}" "$PLIST" >/dev/null 2>&1; then
  launchctl load "$PLIST"
fi
echo "Scheduled daily news for 9:00 AM and 7:00 PM."
echo "Plist: $PLIST"
echo "Wrapper: $WRAPPER"
echo "Logs: $LOG_DIR"
