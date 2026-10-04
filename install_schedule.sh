#!/bin/zsh
set -euo pipefail

LABEL="com.aria.dailynews"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
WRAPPER="$HOME/Library/LaunchAgents/${LABEL}.run.sh"
LOG_DIR="$HOME/Library/Logs/daily-news"
PROJECT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$LOG_DIR"

# launchd cannot use this project path as zsh's script file: the folder
# name has a space and sits under Downloads. Run a wrapper with no spaces
# and call python by absolute path instead of `source ./run.sh`.
cat > "$WRAPPER" <<EOF
#!/bin/zsh
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:\$PATH"
PROJECT=$(printf '%q' "$PROJECT")
cd "\$PROJECT"
if [[ ! -x .venv/bin/python ]]; then
  python3 -m venv .venv
fi
.venv/bin/python -m pip install -q --upgrade pip
.venv/bin/python -m pip install -q -r requirements.txt
.venv/bin/python generate_news.py
/bin/zsh ./deploy_site.sh
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
