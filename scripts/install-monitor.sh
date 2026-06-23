#!/usr/bin/env bash
# Install (or refresh) the swarf launch monitor as a macOS LaunchAgent.
#
# Deploys the monitor to ~/.swarf-monitor/ (a stable, non-iCloud location —
# launchd is sandbox-denied from executing scripts inside iCloud Drive), then
# loads a LaunchAgent that runs it twice daily (09:13 + 21:13 local). Survives
# app-quit and reboot; runs in your login session. Public GitHub/HN APIs only —
# no keychain, no auth.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # repo scripts/ dir
STABLE="${HOME}/.swarf-monitor"
LABEL="com.swarf.monitor"
PLIST="${HOME}/Library/LaunchAgents/${LABEL}.plist"

mkdir -p "${STABLE}" "${HOME}/Library/LaunchAgents"
cp "${SRC}/monitor.py" "${SRC}/run-monitor.sh" "${STABLE}/"
chmod +x "${STABLE}/monitor.py" "${STABLE}/run-monitor.sh"

RUNNER="${STABLE}/run-monitor.sh"
cat > "${PLIST}" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>${LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${RUNNER}</string>
  </array>
  <key>StartCalendarInterval</key>
  <array>
    <dict><key>Hour</key><integer>9</integer><key>Minute</key><integer>13</integer></dict>
    <dict><key>Hour</key><integer>21</integer><key>Minute</key><integer>13</integer></dict>
  </array>
  <key>RunAtLoad</key><false/>
  <key>StandardOutPath</key><string>${STABLE}/launchd.out</string>
  <key>StandardErrorPath</key><string>${STABLE}/launchd.err</string>
</dict>
</plist>
PLIST

launchctl unload "${PLIST}" 2>/dev/null || true
launchctl load "${PLIST}"
echo "deployed to: ${STABLE}"
echo "installed + loaded: ${PLIST}"
echo "schedule: 09:13 and 21:13 local, twice daily"
echo "inbox:    ${STABLE}/INBOX.md"
echo "to remove: launchctl unload '${PLIST}' && rm '${PLIST}' && rm -rf '${STABLE}'"
