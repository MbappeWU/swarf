#!/usr/bin/env python3
"""
swarf launch monitor — checks GitHub (stars / issues / comments) and Hacker News
for NEW activity since the last run. Pure stdlib: no auth, no keychain, no deps,
so it runs fine from launchd / cron against the *public* repo.

Prints one "NEW: …" line per actionable item, or "NO_NEW_ITEMS" when all quiet,
and appends new items to monitor/INBOX.md as a persistent queue for reply drafting.

First run establishes a silent baseline (it does not alert on pre-existing items).
"""
import json, os, sys, datetime, urllib.request

REPO = "MbappeWU/swarf"
# State lives next to this script (so it works both in the repo and when the
# installer copies it to ~/.swarf-monitor/ — launchd can't reach iCloud Drive).
BASE = os.path.dirname(os.path.abspath(__file__))
STATE = os.path.join(BASE, "state.json")
INBOX = os.path.join(BASE, "INBOX.md")
UA = "swarf-monitor"


def get(url):
    req = urllib.request.Request(
        url, headers={"User-Agent": UA, "Accept": "application/vnd.github+json"})
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return json.load(r)
    except Exception:
        return None


def load_state():
    try:
        with open(STATE) as f:
            return json.load(f)
    except Exception:
        return {"stars": 0, "issues": [], "comments": [], "hn": [], "init": False}


st = load_state()
first = not st.get("init")
new = []

repo = get(f"https://api.github.com/repos/{REPO}")
if repo is not None:
    stars = repo.get("stargazers_count", st.get("stars", 0))
    if not first and stars > st.get("stars", 0):
        new.append(f"NEW: stars {st['stars']} -> {stars} (+{stars - st['stars']})")
    st["stars"] = stars

issues = get(f"https://api.github.com/repos/{REPO}/issues"
             "?state=all&per_page=30&sort=created&direction=desc") or []
seen_i = set(st.get("issues", []))
for it in issues:
    num = it.get("number")
    if num is None or num in seen_i:
        continue
    seen_i.add(num)
    if not first:
        kind = "PR" if "pull_request" in it else "issue"
        new.append(f"NEW: {kind} #{num} by @{it['user']['login']}: {it.get('title','')}")
st["issues"] = sorted(seen_i)

comments = get(f"https://api.github.com/repos/{REPO}/issues/comments"
               "?per_page=30&sort=created&direction=desc") or []
seen_c = set(st.get("comments", []))
for c in comments:
    cid = c.get("id")
    if cid is None or cid in seen_c:
        continue
    seen_c.add(cid)
    if not first and c["user"]["login"] != "MbappeWU":
        inum = c.get("issue_url", "").rsplit("/", 1)[-1]
        body = (c.get("body") or "").replace("\n", " ")[:160]
        new.append(f"NEW: comment on #{inum} by @{c['user']['login']}: {body}")
st["comments"] = sorted(seen_c)

hn = get("http://hn.algolia.com/api/v1/search_by_date"
         "?query=swarf&tags=(story,comment)&hitsPerPage=30")
seen_h = set(st.get("hn", []))
if hn:
    for h in hn.get("hits", []):
        oid = h.get("objectID")
        if not oid or oid in seen_h:
            continue
        seen_h.add(oid)
        title = h.get("title") or h.get("story_title") or ""
        url = h.get("url") or ""
        txt = (h.get("comment_text") or "")[:160]
        blob = (title + " " + url + " " + txt).lower()
        rel = ("mbappewu/swarf" in blob) or ("swarf" in blob and any(
            k in blob for k in ("node_modules", "mac", "disk", "cleaner", "derived", "xcode")))
        if not first and rel:
            label = title or txt
            new.append(f"NEW: HN: {label} https://news.ycombinator.com/item?id={oid}")
st["hn"] = sorted(seen_h)

st["init"] = True
st["last_run"] = datetime.datetime.now().isoformat(timespec="seconds")
with open(STATE, "w") as f:
    json.dump(st, f, indent=2)

if new:
    with open(INBOX, "a") as f:
        f.write(f"\n## {st['last_run']}\n")
        for n in new:
            f.write(f"- {n[5:].strip()}\n")  # strip "NEW: " prefix in the file
    print("\n".join(new))
else:
    print("NO_NEW_ITEMS")
