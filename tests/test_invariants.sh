#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd "$repo_root"

expected_skills="financial-advisor
parenting
wellness-coach"
actual_skills=$(find skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

if [ "$actual_skills" != "$expected_skills" ]; then
  printf 'Unexpected skill set:\n%s\n' "$actual_skills" >&2
  exit 1
fi

test ! -e SKILL.md
test -L AGENTS.md
test "$(readlink AGENTS.md)" = "CLAUDE.md"

for skill_name in financial-advisor parenting wellness-coach; do
  test -f "skills/$skill_name/SKILL.md"
  test -f "skills/$skill_name/agents/openai.yaml"
  test "$(sed -n '1p' "skills/$skill_name/SKILL.md")" = "---"
  test "$(sed -n '4p' "skills/$skill_name/SKILL.md")" = "---"
  rg -q "^name: $skill_name$" "skills/$skill_name/SKILL.md"
  description=$(sed -n 's/^description: //p' "skills/$skill_name/SKILL.md")
  if [ "${#description}" -lt 40 ]; then
    printf 'Skill description is missing or too short: %s.\n' "$skill_name" >&2
    exit 1
  fi
  if rg -q 'TODO|\[TODO' "skills/$skill_name"; then
    printf 'Unfinished scaffold content found in %s.\n' "$skill_name" >&2
    exit 1
  fi
  rg -F -q "default_prompt: \"Use \$$skill_name" "skills/$skill_name/agents/openai.yaml"
done

rg -q 'authoritative parenting' skills/parenting/SKILL.md
rg -q 'emotion coaching' skills/parenting/SKILL.md
rg -q 'growth mindset' skills/parenting/SKILL.md
rg -q 'graduated independence' skills/parenting/SKILL.md
rg -q 'FIRE' skills/financial-advisor/SKILL.md
rg -q 'AMT, NIIT, QBI' skills/financial-advisor/SKILL.md
rg -q '1031' skills/financial-advisor/SKILL.md
rg -q 'progressive overload' skills/wellness-coach/SKILL.md
rg -q 'periodization' skills/wellness-coach/SKILL.md
rg -q 'Notion is the sole workout record' templates/data/CLAUDE.md
rg -q 'do not create a local file' skills/wellness-coach/SKILL.md

private_identifier_pattern='/''Users/|Downloads/''family-os|notion\.so/[[:alnum:]]|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
if rg -n "$private_identifier_pattern" \
  --glob '!LICENSE' .; then
  printf 'Public-isolation check found a private path or service identifier.\n' >&2
  exit 1
fi

if find . -type f \( -name 'financial.md' -o -name 'parenting.md' -o -name 'welness.md' \) | rg -q .; then
  printf 'A source prompt appears to have been copied into the logic repository.\n' >&2
  exit 1
fi

printf 'Repository invariants passed.\n'
