#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_root=$(mktemp -d /tmp/household-os-install.XXXXXX)

cleanup() {
  rm -rf "$test_root"
}
trap cleanup EXIT HUP INT TERM

data_dir="$test_root/data repo"
"$repo_root/install.sh" --data-dir "$data_dir" >/dev/null

test -d "$data_dir/.git"
test -f "$data_dir/CLAUDE.md"
test -L "$data_dir/AGENTS.md"
test "$(readlink "$data_dir/AGENTS.md")" = "CLAUDE.md"
test -f "$data_dir/modules/financial-advisor/profile.md"
test -f "$data_dir/modules/parenting/child.md"
test -f "$data_dir/modules/wellness-coach/notion.md"
test -d "$data_dir/modules/financial-advisor/tax"

for skill_name in financial-advisor parenting wellness-coach; do
  for project_dir in .agents .claude; do
    link_path="$data_dir/$project_dir/skills/$skill_name"
    test -L "$link_path"
    test "$(readlink "$link_path")" = "$repo_root/skills/$skill_name"
    test -f "$link_path/SKILL.md"
  done
done

if git -C "$data_dir" remote | rg -q .; then
  printf 'Fresh data repository unexpectedly has a Git remote.\n' >&2
  exit 1
fi

git -C "$data_dir" check-ignore -q .agents/skills/financial-advisor
git -C "$data_dir" check-ignore -q .claude/skills/financial-advisor

printf '\nUser-authored sentinel.\n' >> "$data_dir/modules/financial-advisor/profile.md"
"$repo_root/install.sh" --data-dir "$data_dir" >/dev/null
rg -q 'User-authored sentinel' "$data_dir/modules/financial-advisor/profile.md"

conflict_dir="$test_root/conflict"
mkdir -p "$conflict_dir/.agents/skills"
printf 'unmanaged\n' > "$conflict_dir/.agents/skills/parenting"
if "$repo_root/install.sh" --data-dir "$conflict_dir" >/dev/null 2>&1; then
  printf 'Installer replaced an unmanaged skill path.\n' >&2
  exit 1
fi
rg -q '^unmanaged$' "$conflict_dir/.agents/skills/parenting"

printf 'Installer behavior passed.\n'
