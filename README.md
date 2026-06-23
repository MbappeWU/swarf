# swarf

**Reclaim a Mac developer's disk space — safely.**

`swarf` finds the build artifacts rotting in your code trees (`node_modules`, `target`,
`build`, `.gradle`, `__pycache__`, `Pods`, …) **and** the Apple-specific junk that
cross-platform cleaners ignore (Xcode DerivedData, iOS/Simulator caches, CocoaPods,
SwiftPM). Then it moves them to the Trash — recoverable — instead of `rm -rf`-ing them
into oblivion.

It's **one auditable Bash file**. No dependencies. (Yes — a `node_modules` cleaner that
isn't itself an npm package that installs a `node_modules`.) Read it before you run it.

```
$ swarf scan

  TYPE                         SIZE      AGE  PATH
  npm cache                  2.0 GB     84d  ~/.npm/_cacache
  pip cache                  1.0 GB     76d  ~/Library/Caches/pip
  node_modules               229 MB     75d  ~/code/app/gui/node_modules
  node_modules               187 MB     90d  ~/code/site/node_modules
  target                      96 MB     61d  ~/code/cli/target
  __pycache__                4.1 MB     90d  ~/code/ml/venv/.../__pycache__
  RECLAIMABLE                3.6 GB

Run `swarf clean` to move these to Trash (recoverable).
```

## Why another cleaner?

There are good tools for *parts* of this. None cover a Mac dev's whole junk surface, and
almost all of them permanently delete.

| | node_modules | Rust/Gradle/etc. | Xcode / Simulator / CocoaPods | Trash-first (recoverable) | Verifies it's a real build artifact |
|---|:---:|:---:|:---:|:---:|:---:|
| **swarf** | ✅ | ✅ | ✅ | ✅ | ✅ |
| npkill | ✅ | — | — | — | — |
| kondo / clean-dev-dirs | ✅ | ✅ | — | — | partial |
| DevCleaner for Xcode | — | — | ✅ | — | n/a |

The wedge: **Mac-complete coverage + recoverable deletes + it never deletes a folder by
name alone.** A directory called `node_modules` is only ever touched when a real
`package.json` sits next to it; a `target` needs a `Cargo.toml`; `Pods` needs a `Podfile`.
Name a random folder `node_modules` and swarf leaves it alone.

## Install

> Single file — inspect it, then drop it on your `PATH`.

```bash
curl -fsSL https://raw.githubusercontent.com/MbappeWU/swarf/main/swarf -o /usr/local/bin/swarf
chmod +x /usr/local/bin/swarf
```

Or clone and symlink:

```bash
git clone https://github.com/MbappeWU/swarf.git
ln -s "$PWD/swarf/swarf" /usr/local/bin/swarf
```

Requires macOS + Bash (the system `/bin/bash` 3.2 is fine). No Node, no Python, no Rust.

## Usage

```bash
swarf scan                      # read-only — show what's reclaimable
swarf scan ~/work               # scan a specific tree
swarf clean                     # move matches to Trash (asks first)
swarf clean --older-than 180    # only artifacts untouched for 180+ days
swarf clean --type node_modules --yes
swarf scan --no-apple           # project trees only; skip global caches
swarf clean --dry-run           # preview; touch nothing
```

**Filters:** `--older-than DAYS`, `--min-size MB`, `--type T1,T2`, `--no-apple`
**Clean:** `--dry-run`, `--yes`, `--delete` (permanent instead of Trash)

`scan` is always read-only. `clean` moves to `~/.Trash` by default and asks before doing
anything. Pass `--delete` only if you want to skip the Trash.

## What it touches

**Project trees** (only when a real project marker sits beside the folder):
`node_modules` (package.json), `target` (Cargo.toml), `build` (build.gradle/pom.xml/CMakeLists),
`.gradle`, `.dart_tool` (pubspec.yaml), `Pods` (Podfile), `.next`/`.turbo`/`.svelte-kit`
(package.json), `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache`.

**Apple / global caches** (safe by location):
Xcode DerivedData, iOS/watchOS/tvOS DeviceSupport, CoreSimulator caches, SwiftPM cache,
CocoaPods cache, Gradle/npm/Yarn/pip caches.

It never touches your source, your `~/Documents`, `~/Desktop`, keychains, SSH/GPG keys, or
anything under `/System`, `/usr`, etc. See the `PROTECTED` list at the top of the script.

## Safety model

1. **Trash-first.** Everything goes to `~/.Trash`. Recover it from Finder for 30 days.
   Permanent deletion requires an explicit `--delete`.
2. **Marker-verified.** A folder is a candidate only if a real build/manifest file proves
   it's a regenerable artifact — never by name alone.
3. **Hard-protected paths.** A denylist of system and sensitive paths is refused outright,
   including anything reachable via `..`.
4. **Read-only by default.** `scan` never writes. `clean` previews and asks first.

## FAQ

**Will I lose work?** Build artifacts are regenerable — `npm install`, `cargo build`,
re-open Xcode. And it's trash-first, so even a mistake is recoverable.

**Why Bash?** So you can read the entire thing in five minutes and trust it. A disk cleaner
should not be a black box.

**Does it auto-run / phone home?** No. No telemetry, no network, no background agent.

## License

MIT © 2026. See [LICENSE](LICENSE).
