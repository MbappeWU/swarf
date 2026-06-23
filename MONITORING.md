# swarf launch monitor

A two-layer mechanism to catch GitHub/HN activity during the launch and help reply —
**without** ever auto-posting to strangers.

## Layer 1 — persistent monitor (always on)

A macOS **LaunchAgent** runs `monitor.py` twice daily (09:13 + 21:13 local). It checks
the **public** GitHub API (stars, issues, comments) and Hacker News (Algolia) for new
activity since the last run. On anything new it appends to `~/.swarf-monitor/INBOX.md`
and fires a desktop notification. Survives app-quit and reboot; runs in your login
session. Public APIs only — no auth, no keychain, no telemetry.

Deployed to `~/.swarf-monitor/` because launchd is sandbox-denied from executing scripts
inside iCloud Drive (where this repo lives).

```bash
bash scripts/install-monitor.sh     # install / refresh
launchctl start com.swarf.monitor   # run once now
tail -f ~/.swarf-monitor/run.log    # watch
```

Remove:

```bash
launchctl unload ~/Library/LaunchAgents/com.swarf.monitor.plist
rm ~/Library/LaunchAgents/com.swarf.monitor.plist
rm -rf ~/.swarf-monitor
```

## Layer 2 — reply drafter (when Claude Code is open)

A scheduled Claude job reads `~/.swarf-monitor/INBOX.md` and, for any item without a draft
yet, writes a reply draft to `~/.swarf-monitor/REPLIES-TO-SEND.md` — in your voice, with
the exact post command — then pings you. **It never posts anything.** You review and send.

If Claude Code is closed when something lands, Layer 1 still notifies you and queues it in
`INBOX.md`; just open Claude and ask it to draft replies from the inbox.

## Why drafts, not auto-replies

Auto-posting LLM-written replies to real developers during a launch is a fast way to lose
credibility. The monitor surfaces and drafts; a human approves and sends. If you later want
templated auto-acknowledgements for, say, new issues, that's a deliberate opt-in.

## Files

| File | Role |
|---|---|
| `scripts/monitor.py` | the monitor (stdlib only; public APIs) |
| `scripts/run-monitor.sh` | wrapper: run + notify on new |
| `scripts/install-monitor.sh` | deploy to `~/.swarf-monitor/` + load LaunchAgent |
| `~/.swarf-monitor/INBOX.md` | queue of new activity (runtime) |
| `~/.swarf-monitor/REPLIES-TO-SEND.md` | drafted replies awaiting your approval (runtime) |
