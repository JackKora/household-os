#!/usr/bin/env bash
set -euo pipefail
repo=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P); root=$(mktemp -d /tmp/household-os-install.XXXXXX); root=$(CDPATH= cd -- "$root" && pwd -P); trap 'rm -rf "$root"' EXIT
fail(){ echo "$1" >&2; exit 1; }; notready(){ ! rg -q 'Household OS is ready' "$1"; }; mode(){ stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1"; }
data="$root/data"; HOUSEHOLD_OS_DATA_DIR="$root/ignored" "$repo/install.sh" --data-dir "$data" </dev/null > "$root/explicit"
rg -F -q "Data repository: $data" "$root/explicit"; ! rg -q 'Household OS data directory' "$root/explicit"; [ ! -e "$root/ignored" ]
for s in financial-advisor general-contractor legal-advisor parenting wellness-coach; do for b in .agents .claude; do [ "$(readlink "$data/$b/skills/$s")" = "$repo/skills/$s" ] || fail bad-link; done; done
[ "$(mode "$data")" = 700 ] && [ "$(mode "$data/CLAUDE.md")" = 600 ]; ! git -C "$data" remote | rg -q .
for d in modules/financial-advisor/tax modules/general-contractor/projects modules/legal-advisor/matters modules/financial-advisor/notes modules/general-contractor/notes modules/legal-advisor/notes modules/parenting/notes modules/wellness-coach/notes notes; do [ ! -e "$data/$d" ] || fail "unexpected eager directory: $d"; done
[ -f "$data/modules/general-contractor/property.md" ] && [ ! -L "$data/modules/general-contractor/property.md" ] || fail gc-property
envdata="$root/env"; HOUSEHOLD_OS_DATA_DIR="$envdata" "$repo/install.sh" </dev/null >/dev/null; [ -d "$envdata/.git" ]
home="$root/home"; mkdir "$home"; if env -u HOUSEHOLD_OS_DATA_DIR HOME="$home" "$repo/install.sh" </dev/null > "$root/no-config" 2>&1; then fail no-config; fi; rg -q 'requires --data-dir or exported HOUSEHOLD_OS_DATA_DIR' "$root/no-config"; notready "$root/no-config"; [ ! -e "$home/household-os-data" ]
if command -v expect >/dev/null; then prompt="$root/prompt"; TEST_INSTALL="$repo/install.sh" TEST_DATA="$prompt" expect -c 'spawn -noecho env HOME=/tmp HOUSEHOLD_OS_DATA_DIR=$env(TEST_DATA) $env(TEST_INSTALL); expect -exact [format {Household OS data directory [%s]: } $env(TEST_DATA)]; send -- "\r"; expect eof; exit [lindex [wait] 3]' >/dev/null; [ -d "$prompt/.git" ]; else echo 'TTY prompt test skipped: expect unavailable.'; fi
if "$repo/install.sh" --data-dir / </dev/null > "$root/root" 2>&1; then fail root; fi; notready "$root/root"
safehome="$root/safe-home"; mkdir "$safehome"; if HOME="$safehome" "$repo/install.sh" --data-dir "$safehome" </dev/null > "$root/home.out" 2>&1; then fail home; fi; notready "$root/home.out"
if "$repo/install.sh" --data-dir "$repo/no-install-here" </dev/null > "$root/danger" 2>&1; then fail dangerous; fi; notready "$root/danger"
if "$repo/install.sh" --data-dir "$repo/child/../no-install-here" </dev/null > "$root/dots" 2>&1; then fail dots; fi; notready "$root/dots"; [ ! -e "$repo/no-install-here" ]
mkdir "$root/unrelated"; echo keep > "$root/unrelated/file"; if "$repo/install.sh" --data-dir "$root/unrelated" </dev/null >/dev/null 2>&1; then fail unrelated; fi; [ "$(cat "$root/unrelated/file")" = keep ]
git init -q "$root/outer"; if "$repo/install.sh" --data-dir "$root/outer/data" </dev/null >/dev/null 2>&1; then fail nested; fi; [ ! -e "$root/outer/data" ]
echo user >> "$data/modules/financial-advisor/profile.md"; echo property-user >> "$data/modules/general-contractor/property.md"; echo custom > "$data/.gitignore"; "$repo/install.sh" --data-dir "$data" </dev/null >/dev/null; rg -q user "$data/modules/financial-advisor/profile.md"; rg -q property-user "$data/modules/general-contractor/property.md"; for d in modules/financial-advisor/tax modules/general-contractor/projects modules/legal-advisor/matters modules/financial-advisor/notes modules/general-contractor/notes modules/legal-advisor/notes modules/parenting/notes modules/wellness-coach/notes notes; do [ ! -e "$data/$d" ] || fail "unexpected eager directory: $d"; done; [ "$(cat "$data/.gitignore")" = custom ]; for e in .household-os/ .agents/skills/ .claude/skills/; do [ "$(grep -F -x -c "$e" "$data/.git/info/exclude")" = 1 ] || fail excludes; done
outside="$root/external-agents"
mkdir -p "$outside/skills"
echo keep > "$outside/sentinel"
rm -rf "$data/.agents"
ln -s "$outside" "$data/.agents"
if "$repo/install.sh" --data-dir "$data" </dev/null > "$root/ancestor-symlink.out" 2>&1; then fail ancestor-symlink; fi
notready "$root/ancestor-symlink.out"
[ "$(cat "$outside/sentinel")" = keep ]
for s in financial-advisor general-contractor legal-advisor parenting wellness-coach; do
  [ ! -e "$outside/skills/$s" ] && [ ! -L "$outside/skills/$s" ] || fail external-skill-link
done
conflict="$root/conflict"; "$repo/install.sh" --data-dir "$conflict" </dev/null >/dev/null; unlink "$conflict/.agents/skills/parenting"; echo bad > "$conflict/.agents/skills/parenting"; rm "$conflict/modules/legal-advisor/profile.md"; if "$repo/install.sh" --data-dir "$conflict" </dev/null > "$root/conflict.out" 2>&1; then fail conflict; fi; [ ! -e "$conflict/modules/legal-advisor/profile.md" ] && notready "$root/conflict.out"
relocate="$root/relocate"; "$repo/install.sh" --data-dir "$relocate" </dev/null >/dev/null; old="$root/old"; echo "$old" > "$relocate/.household-os/logic-root"; for s in financial-advisor general-contractor legal-advisor parenting wellness-coach; do for b in .agents .claude; do unlink "$relocate/$b/skills/$s"; ln -s "$old/skills/$s" "$relocate/$b/skills/$s"; done; done; "$repo/install.sh" --data-dir "$relocate" </dev/null >/dev/null; [ "$(readlink "$relocate/.claude/skills/legal-advisor")" = "$repo/skills/legal-advisor" ]
echo '<!-- marker only -->' > "$relocate/CLAUDE.md"; rm "$relocate/modules/legal-advisor/profile.md"; if "$repo/install.sh" --data-dir "$relocate" </dev/null > "$root/stale" 2>&1; then fail stale; fi; notready "$root/stale"; [ ! -e "$relocate/modules/legal-advisor/profile.md" ]
! rg -q 'SKILL\.md|skills/.+\[.*-e|skills/.+\[.*-f' "$repo/install.sh"
echo 'Installer behavior passed.'
