# Household OS

Household OS is a file-based operating system for personal and family decisions. It provides five focused skills:

- Financial Advisor
- General Contractor
- Legal Advisor
- Parenting
- Wellness Coach

Reusable methodology lives in this repository. Personal household context lives in a separate data repository.

## Install

```bash
./install.sh
```

In an interactive shell, the installer prompts once for the data directory. Press Enter to accept `~/household-os-data`, or enter another path. You can export a preferred location; it is displayed as the prompt's candidate so you can confirm or replace it:

```bash
export HOUSEHOLD_OS_DATA_DIR=/absolute/path/to/household-os-data
./install.sh
```

An explicit command-line path takes precedence over the environment and skips the prompt:

```bash
./install.sh --data-dir /absolute/path/to/household-os-data
```

When standard input is not a terminal, the installer requires either `--data-dir` or a nonempty exported `HOUSEHOLD_OS_DATA_DIR`; it never silently chooses the default. The installer reads the exported environment only and does not inspect shell startup files.

The installer:

- validates the destination before changing it, then creates the private data repository while preserving existing regular files
- initializes local Git for version history
- connects the five skills to Codex through `.agents/skills/`
- connects the five skills to Claude Code through `.claude/skills/`
- shares one set of runtime instructions through `CLAUDE.md` and `AGENTS.md`

The destination must be new, empty, or an existing Household OS data repository created by this installer. It cannot be the public logic repository, a directory inside it, or a directory inside another Git repository. On an existing installation, customized runtime instructions are preserved and must be reconciled with `templates/data/CLAUDE.md` before the installer will continue.

Open Codex or Claude Code from the data repository to use Household OS with private household context:

```bash
cd ~/household-os-data
```

Then ask to activate one module or all five. During activation, provide the source notes when prompted. Household OS separates personal facts from methodology, shows the proposed baseline for review, and writes only after approval.

## How routing works

`CLAUDE.md` and its `AGENTS.md` symlink route each request by primary intent. Skill descriptions provide the same trigger boundaries to Codex and Claude Code. Household OS loads the relevant skill and private files, combining skills when a decision genuinely crosses domains.

## Persistence

Household OS defaults to not saving. It keeps fixed, reviewed baseline files and can save free-form research, plans, projects, matters, decisions, trends, tasks, sources, and outcomes as Markdown notes.

- **Location:** Put a note in its primary module: `modules/financial-advisor/notes/`, `modules/general-contractor/notes/`, `modules/legal-advisor/notes/`, `modules/parenting/notes/`, or `modules/wellness-coach/notes/`. Use top-level `notes/` only for genuinely cross-functional content with no clear primary module.
- **Note operations:** Ask conversationally to create, add, show, list, search, rename, or move a note.
- **Lifecycle:** Notes are created lazily, are not loaded automatically, and remain until the user manually deletes the file. Deleted files may remain in private Git history.
- **Review:** User-provided note content may be written directly. Assistant-generated or materially summarized content is shown for review first.

### Sensitive legal content

Legal material is the owner's choice, with an extra safeguard against accidental persistence.

- Do not treat ordinary conversation, a question, or sharing material as permission to save it.
- When the user explicitly asks to save user-provided legal research, narratives, strategy, attorney communications, evidence, documents, or other sensitive material, give a concise warning first that repository access or sync and Git history can retain or expose it, then save it.
- Show assistant-generated or materially summarized legal research, analysis, or strategy for review and obtain explicit approval before saving.
- Household members' interests may not align. For exceptionally sensitive material, recommend encrypted, non-Git storage, but do not override the user's explicit choice.

### Workout history

The user's configured Notion database is the sole workout history. A working Notion connection is required to save a generated workout.

## Development

Run all checks with:

```bash
./tests/run.sh
```

Skill structure follows the official [Codex skills guidance](https://learn.chatgpt.com/docs/build-skills) and [Claude Code skills guidance](https://code.claude.com/docs/en/slash-commands).

## License

MIT
