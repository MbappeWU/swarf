# Show HN draft — swarf

> Post Tue–Thu, ~9–11am US Eastern (北京时间 21:00–23:00). Submit at
> https://news.ycombinator.com/submit with the GitHub URL as the link.
> **Before posting:** run `swarf scan` on your own Mac and paste YOUR real number into
> the comment — your number is the hook, not mine.

---

## Title

```
Show HN: Swarf – reclaim a Mac dev's disk space (node_modules + Xcode junk), trash-first
```

(Alternatives, pick the one that reads cleanest:)
- `Show HN: Swarf – a single Bash file that reclaims dev disk space, recoverably`
- `Show HN: Swarf – npkill, but Mac-complete and it moves to Trash instead of rm -rf`

## URL

```
https://github.com/MbappeWU/swarf
```

## First comment (post immediately after submitting)

```
I'm a Mac dev and my disk is always full of regenerable junk. There are good tools for
pieces of this — npkill for node_modules, kondo for build dirs, DevCleaner for Xcode — but
I wanted one pass that covers a Mac dev's *whole* surface, and I didn't love that most of
them permanently delete. So I wrote swarf.

Two things make it different from `rm -rf`:

1. Trash-first. Everything moves to ~/.Trash, recoverable for 30 days. Permanent delete is
   opt-in (--delete).
2. Marker-verified. A folder named `node_modules` is only ever touched when a real
   package.json sits next to it; `target` needs Cargo.toml, `Pods` needs a Podfile, etc.
   It never deletes a folder by name alone.

Coverage in one scan: node_modules / target / build / .gradle / .dart_tool / Pods /
__pycache__ across your code trees, PLUS the Apple stuff cross-platform cleaners skip —
Xcode DerivedData, iOS/Simulator caches, CocoaPods, SwiftPM, and the npm/pip/Gradle caches.

It's one auditable Bash file, no dependencies — which felt right for a tool that deletes
things. You can read the whole thing before trusting it.

Ran it on my own machine just now: 3.6 GB reclaimable (2 GB of that was a stale npm cache,
1 GB a pip cache, the rest node_modules across five dead side projects).

  swarf scan                 # read-only, shows what's reclaimable
  swarf clean --older-than 180   # only stuff you haven't touched in 6 months

Honest about where it sits: this is a crowded niche and v0.1. The bet is that "Mac-complete
+ recoverable + verifies before it deletes" is the combination nobody quite ships. Would
love feedback on the safety model and on artifact types I'm missing (Unity? Unreal?
Android SDK images? .NET bin/obj?).

Repo: https://github.com/MbappeWU/swarf
```

## Rules of engagement (the part that actually decides the outcome)

- **Reply to every comment within the first 2 hours.** HN ranking rewards engagement
  velocity; the first 2 hours decide everything.
- **Never ask for upvotes.** Anywhere. It gets posts flagged.
- **"Power users don't need this / just use `rm -rf`"** → agree, then: "Totally — the value
  is the recoverable + verified part, and covering Xcode/Simulator junk in the same pass."
- **Someone finds a bug** → thank them, fix it that day, reply with the commit. A live fix
  during the thread is the best credibility you can buy.
- **Feature requests** → "Good call, opening an issue" — and actually open it. Every issue
  is a returning visitor.
- Cross-post the same thing to r/macapps and lobste.rs only **after** HN, never simultaneously.
```
