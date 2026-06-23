#!/usr/bin/env bash
# Runs the swarf monitor; on NEW activity fires a macOS notification.
# Invoked by the LaunchAgent (com.swarf.monitor) from ~/.swarf-monitor/.
# Self-locating: monitor.py and state live next to this script.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${DIR}/run.log"

PY="/usr/bin/python3"
[ -x "${PY}" ] || PY="$(command -v python3 2>/dev/null || echo python3)"

out="$("${PY}" "${DIR}/monitor.py" 2>>"${LOG}")" || out="monitor failed"
printf '[%s] %s\n' "$(date '+%F %T')" "${out//$'\n'/ | }" >> "${LOG}"

if [ -n "${out}" ] && [ "${out}" != "NO_NEW_ITEMS" ] && [ "${out}" != "monitor failed" ]; then
    count="$(printf '%s\n' "${out}" | grep -c '^NEW:')"
    /usr/bin/osascript -e "display notification \"${count} new item(s) — review ~/.swarf-monitor/INBOX.md\" with title \"swarf monitor\" sound name \"Submarine\"" 2>/dev/null || true
fi
