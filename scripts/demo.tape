# vhs tape for the swarf README demo.
# Regenerate with:  cd <repo> && vhs scripts/demo.tape   (needs: vhs, ttyd, ffmpeg)
# Records against a throwaway synthetic fixture — no real paths are shown.

Output assets/demo.gif

Set Shell "bash"
Set FontFamily "Menlo"
Set FontSize 16
Set Width 1180
Set Height 680
Set Padding 20
Set Theme "Dracula"
Set TypingSpeed 45ms

# ---- hidden setup: put swarf on PATH + build a backdated fixture ----
Hide
Type `export PATH="$PWD:$PATH"; export PS1="\\[\\e[35m\\]~/code\\[\\e[0m\\] $ "` Enter
Type `D="$HOME/swarf-demo"; rm -rf "$D"` Enter
Type `mkdir -p "$D/web-dashboard/node_modules" "$D/api-server/node_modules" "$D/rust-cli/target" "$D/ml-pipeline/__pycache__"` Enter
Type `echo '{}' > "$D/web-dashboard/package.json"; echo '{}' > "$D/api-server/package.json"; echo '[package]' > "$D/rust-cli/Cargo.toml"` Enter
Type `dd if=/dev/zero of="$D/web-dashboard/node_modules/x" bs=1m count=620 2>/dev/null` Enter
Type `dd if=/dev/zero of="$D/rust-cli/target/x" bs=1m count=360 2>/dev/null` Enter
Type `dd if=/dev/zero of="$D/api-server/node_modules/x" bs=1m count=240 2>/dev/null` Enter
Type `dd if=/dev/zero of="$D/ml-pipeline/__pycache__/x" bs=1m count=18 2>/dev/null` Enter
Type `touch -t 202604091200 "$D/web-dashboard/node_modules"` Enter
Type `touch -t 202603251200 "$D/api-server/node_modules"` Enter
Type `touch -t 202604241200 "$D/rust-cli/target"` Enter
Type `touch -t 202602231200 "$D/ml-pipeline/__pycache__"` Enter
Type "clear" Enter
Show

# ---- the demo ----
Sleep 600ms
Type "swarf scan ~/swarf-demo --no-apple" Sleep 400ms Enter
Sleep 4.5s
Type "swarf clean ~/swarf-demo --no-apple --dry-run" Sleep 400ms Enter
Sleep 4.5s
