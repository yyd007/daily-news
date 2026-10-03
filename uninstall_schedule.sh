#!/bin/zsh
set -euo pipefail

LABEL="com.aria.dailynews"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"

if [[ -f "$PLIST" ]]; then
  launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
  launchctl unload "$PLIST" >/dev/null 2>&1 || true
  rm -f "$PLIST"
fi

echo "Daily news schedule removed."
