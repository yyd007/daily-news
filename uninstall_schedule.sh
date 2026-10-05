#!/bin/zsh
set -euo pipefail

LABEL="com.aria.dailynews"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
WRAPPER="$HOME/Library/LaunchAgents/${LABEL}.run.sh"

if [[ -f "$PLIST" ]]; then
  launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
  launchctl bootout "gui/$(id -u)/${LABEL}" >/dev/null 2>&1 || true
  launchctl unload "$PLIST" >/dev/null 2>&1 || true
  rm -f "$PLIST"
fi
rm -f "$WRAPPER"

echo "Daily news schedule removed."
echo "Project copy at $HOME/daily-news was left in place."
