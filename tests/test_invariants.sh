#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd "$repo_root"

expected_skills="financial-advisor
general-contractor
legal-advisor
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

for skill_name in financial-advisor general-contractor legal-advisor parenting wellness-coach; do
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
expected_general_contractor_references="diagnosis-and-repair.md
projects-and-contractors.md"
actual_general_contractor_references=$(find skills/general-contractor/references -mindepth 1 -maxdepth 1 -type f -name '*.md' -exec basename {} \; | sort)
if [ "$actual_general_contractor_references" != "$expected_general_contractor_references" ]; then
  printf 'Unexpected general-contractor reference set:\n%s\n' "$actual_general_contractor_references" >&2
  exit 1
fi
for reference_name in diagnosis-and-repair projects-and-contractors; do
  rg -F -q "references/$reference_name.md" skills/general-contractor/SKILL.md
done
for reference_name in \
  household-issue-map \
  authority-and-research \
  planning-and-document-review \
  disputes-and-procedure; do
  test -f "skills/legal-advisor/references/$reference_name.md"
  rg -F -q "references/$reference_name.md" skills/legal-advisor/SKILL.md
done
rg -q 'progressive overload' skills/wellness-coach/SKILL.md
rg -q 'periodization' skills/wellness-coach/SKILL.md
rg -q '^## Use universal notes deliberately$' templates/data/CLAUDE.md
for note_path in \
  modules/financial-advisor/notes/ \
  modules/general-contractor/notes/ \
  modules/legal-advisor/notes/ \
  modules/parenting/notes/ \
  modules/wellness-coach/notes/; do
  rg -F -q "\`$note_path\`" templates/data/CLAUDE.md
done
rg -F -q 'Use top-level `notes/` only for genuinely cross-functional content with no clear primary module.' templates/data/CLAUDE.md
rg -F -q 'create, add to, show, list, search, rename, and move notes' templates/data/CLAUDE.md
rg -F -q 'Create a `notes/` directory only when creating or moving the first note into it.' templates/data/CLAUDE.md
rg -F -q 'Do not load notes automatically' templates/data/CLAUDE.md
rg -F -q 'Do not create archives, lifecycle or status schemes, managed delete commands, placeholder files, automatic migrations, legacy fallbacks, or compatibility storage.' templates/data/CLAUDE.md
rg -F -q 'do not treat ordinary conversation, a question, or the user' templates/data/CLAUDE.md
rg -F -q 'An explicit request to save does authorize saving user-provided legal research' templates/data/CLAUDE.md
rg -F -q 'repository access or sync and Git history' templates/data/CLAUDE.md
rg -F -q 'assistant-generated or materially summarized legal research, analysis, or strategy' templates/data/CLAUDE.md
rg -F -q 'recommend encrypted, non-Git storage' templates/data/CLAUDE.md
rg -F -q 'do not override an explicit user choice to save it here' templates/data/CLAUDE.md
rg -F -q "Legal material is the owner's choice" README.md
rg -F -q 'Do not treat ordinary conversation, a question, or sharing material as permission to save it.' README.md
rg -F -q 'give a concise warning first that repository access or sync and Git history can retain or expose it' README.md
rg -F -q 'Show assistant-generated or materially summarized legal research, analysis, or strategy for review' README.md
rg -F -q 'recommend encrypted, non-Git storage, but do not override the user' README.md
rg -F -q 'Sensitive legal content is saved only on your explicit request' templates/data/README.md
rg -F -q 'repository access or sync and Git history can retain or expose it' templates/data/README.md
rg -F -q 'requires your explicit review and approval before saving' templates/data/README.md
rg -F -q 'does not override your explicit choice' templates/data/README.md
rg -q 'Notion is the sole workout record' templates/data/CLAUDE.md
rg -q 'do not create a local file' skills/wellness-coach/SKILL.md
rg -q 'Workout entries and recorded results belong only in Notion' skills/wellness-coach/SKILL.md

obsolete_private_storage_pattern='modules/(financial-advisor/tax|financial-advisor/decisions\.md|general-contractor/projects|legal-advisor/matters|parenting/trends\.md|wellness-coach/trends\.md)'
if rg -n "$obsolete_private_storage_pattern" --glob '!tests/**' .; then
  printf 'Obsolete private storage reference found.\n' >&2
  exit 1
fi
test -f skills/general-contractor/references/projects-and-contractors.md

private_identifier_pattern='/''Users/|Downloads/''family-os|notion\.so/[[:alnum:]]|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
if rg -n "$private_identifier_pattern" \
  --glob '!LICENSE' .; then
  printf 'Public-isolation check found a private path or service identifier.\n' >&2
  exit 1
fi

if find . -type f \( -name 'financial.md' -o -name 'legal.md' -o -name 'parenting.md' -o -name 'welness.md' \) | rg -q .; then
  printf 'A source prompt appears to have been copied into the logic repository.\n' >&2
  exit 1
fi

printf 'Repository invariants passed.\n'
