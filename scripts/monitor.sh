#!/usr/bin/env bash
# ==============================================================================
# swarf/scripts/monitor.sh — launch monitor.
#
# Checks GitHub (stars, new issues, new comments) and Hacker News for new,
# actionable activity since the last run. Prints "NEW: …" lines for anything
# that needs the maintainer's attention, or "NO_NEW_ITEMS" when all quiet.
#
# Designed to be run on a schedule. It is SILENT (NO_NEW_ITEMS) unless something
# actually happened — no noise, no daily report nobody reads.
#
# Requires: gh (authenticated), curl, python3.
# ==============================================================================
set -uo pipefail

REPO="MbappeWU/swarf"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MON="${DIR}/monitor"
mkdir -p "${MON}"
SEEN_ISSUES="${MON}/.seen_issues"
SEEN_COMMENTS="${MON}/.seen_comments"
SEEN_HN="${MON}/.seen_hn"
STARS_FILE="${MON}/.stars"
touch "${SEEN_ISSUES}" "${SEEN_COMMENTS}" "${SEEN_HN}"

NEWFILE="$(mktemp)"
trap 'rm -f "${NEWFILE}"' EXIT
TS="$(date '+%F %T')"
DIGEST="${MON}/digest-$(date +%F).md"
{ echo "# swarf monitor — ${TS}"; echo; } > "${DIGEST}"

# ------------------------------------------------------------------ GitHub stats
stats="$(gh api "repos/${REPO}" \
    --jq '"\(.stargazers_count) \(.forks_count) \(.open_issues_count) \(.subscribers_count)"' 2>/dev/null)" || stats=""
read -r STARS FORKS OPENI WATCHERS <<< "${stats:-0 0 0 0}"
PREV_STARS="$(cat "${STARS_FILE}" 2>/dev/null || echo 0)"
printf 'Stars: %s (prev %s) · Forks: %s · Watchers: %s · Open issues: %s\n' \
    "${STARS}" "${PREV_STARS}" "${FORKS}" "${WATCHERS}" "${OPENI}" >> "${DIGEST}"
if [ "${STARS:-0}" -gt "${PREV_STARS:-0}" ] 2>/dev/null; then
    echo "NEW: ⭐ stars ${PREV_STARS} → ${STARS} (+$((STARS - PREV_STARS)))" >> "${NEWFILE}"
fi
[ -n "${STARS:-}" ] && echo "${STARS}" > "${STARS_FILE}"

# ------------------------------------------------------------------- New issues
gh api "repos/${REPO}/issues?state=all&sort=created&direction=desc&per_page=30" \
    --jq '.[] | select(.pull_request==null) | "\(.number)\t\(.user.login)\t\(.title)"' 2>/dev/null \
| while IFS=$'\t' read -r num user title; do
    [ -z "${num}" ] && continue
    if ! grep -qx "${num}" "${SEEN_ISSUES}" 2>/dev/null; then
        echo "${num}" >> "${SEEN_ISSUES}"
        echo "NEW: 🐛 issue #${num} by @${user}: ${title}" >> "${NEWFILE}"
        echo "- issue #${num} by @${user}: ${title}" >> "${DIGEST}"
    fi
done

# ----------------------------------------------------------------- New comments
gh api "repos/${REPO}/issues/comments?sort=created&direction=desc&per_page=30" \
    --jq '.[] | "\(.id)\t\(.user.login)\t\(.issue_url | sub(".*/";""))\t\(.body | gsub("[\n\r]";" ") | .[0:160])"' 2>/dev/null \
| while IFS=$'\t' read -r cid user issuenum body; do
    [ -z "${cid}" ] && continue
    if ! grep -qx "${cid}" "${SEEN_COMMENTS}" 2>/dev/null; then
        echo "${cid}" >> "${SEEN_COMMENTS}"
        # skip our own comments
        [ "${user}" = "MbappeWU" ] && continue
        echo "NEW: 💬 comment on #${issuenum} by @${user}: ${body}" >> "${NEWFILE}"
        echo "- comment on #${issuenum} by @${user}: ${body}" >> "${DIGEST}"
    fi
done

# -------------------------------------------------------------------- Hacker News
hn="$(curl -s --max-time 20 \
    'http://hn.algolia.com/api/v1/search_by_date?query=swarf&tags=(story,comment)&hitsPerPage=30' 2>/dev/null)" || hn=""
if [ -n "${hn}" ]; then
    printf '%s' "${hn}" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for h in d.get("hits", []):
    oid = h.get("objectID") or ""
    title = h.get("title") or h.get("story_title") or ""
    url = h.get("url") or ""
    txt = (h.get("comment_text") or "")[:160]
    blob = (title + " " + url + " " + txt).lower()
    rel = ("mbappewu/swarf" in blob) or ("swarf" in blob and any(
        k in blob for k in ("node_modules","mac","disk","cleaner","derived","xcode")))
    label = title or txt
    print(f"{oid}\t{1 if rel else 0}\t{label}\t{url}")
' 2>/dev/null \
    | while IFS=$'\t' read -r oid rel label url; do
        [ -z "${oid}" ] && continue
        if ! grep -qx "${oid}" "${SEEN_HN}" 2>/dev/null; then
            echo "${oid}" >> "${SEEN_HN}"
            if [ "${rel}" = "1" ]; then
                echo "NEW: 📰 HN: ${label} — https://news.ycombinator.com/item?id=${oid} ${url}" >> "${NEWFILE}"
                echo "- HN: ${label} (item ${oid})" >> "${DIGEST}"
            fi
        fi
    done
fi

# ------------------------------------------------------------------------ Output
if [ -s "${NEWFILE}" ]; then
    cat "${NEWFILE}"
else
    echo "NO_NEW_ITEMS"
fi
