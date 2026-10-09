# Household OS development instructions

This repository contains reusable, public-safe logic. It must never contain household data.

## Invariants

- Keep exactly six independent skills: `financial-advisor`, `general-contractor`, `legal-advisor`, `parenting`, `political-advisor`, and `wellness-coach`.
- Keep all people, relationships, dates of birth, addresses, employers, accounts, balances, properties, health details, habits, preferences, private values, service identifiers, and source-file paths out of this repository.
- Preserve generally applicable frameworks, books, authors, and methodologies when refining a skill. Generalize distinctive household wording without discarding its useful method.
- Keep routing and persistence policy in the data repository's `CLAUDE.md`; keep domain methodology in each skill.
- Treat Notion as the sole workout store. Never introduce a local workout fallback.
- Use current primary sources for time-sensitive financial, construction, legal, medical, or developmental claims. For construction claims, verify the locally adopted code and manufacturer requirements when material. For legal claims, also verify the law in effect on the relevant historical date when it may control.
- Verify current political and social claims with primary sources, distinguish evidence from values, and apply consistent standards without forced ideological balance.

## Changes

- Keep the implementation simple and file-based.
- Do not overwrite data-repository files during installation or upgrade.
- Maintain both Codex project links (`.agents/skills`) and Claude Code project links (`.claude/skills`).
- Run `./tests/run.sh` after changes.
- Perform a manual public-isolation review before publishing.
