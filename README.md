# Household OS

Household OS is a file-based operating system for personal and family decisions. It provides three focused skills:

- Financial Advisor
- Parenting
- Wellness Coach

Reusable methodology lives in this repository. Personal household context lives in a separate data repository, `~/household-os-data` by default.

## Install

```bash
./install.sh
```

To use a different data location:

```bash
./install.sh --data-dir /absolute/path/to/household-os-data
```

The installer:

- creates the data repository while preserving existing files
- initializes local Git for version history
- connects the three skills to Codex through `.agents/skills/`
- connects the three skills to Claude Code through `.claude/skills/`
- shares one set of runtime instructions through `CLAUDE.md` and `AGENTS.md`

Open Codex or Claude Code from the data repository to use Household OS with private household context:

```bash
cd ~/household-os-data
```

Then ask to activate one module or all three. During activation, provide the source notes when prompted. Household OS separates personal facts from methodology, shows the proposed baseline for review, and writes only after approval.

## How routing works

`CLAUDE.md` and its `AGENTS.md` symlink route each request by primary intent. Skill descriptions provide the same trigger boundaries to Codex and Claude Code. Household OS loads the relevant skill and private files, combining skills when a decision genuinely crosses domains.

## Persistence

Household OS keeps reviewed baseline facts, material profile changes, finalized decisions and plans, recurring trends across separate events, and anything explicitly requested for memory. Everyday conversation remains conversational context.

The user's configured Notion database is the workout history. A working Notion connection is required to save a generated workout.

## Development

Run all checks with:

```bash
./tests/run.sh
```

Skill structure follows the official [Codex skills guidance](https://learn.chatgpt.com/docs/build-skills) and [Claude Code skills guidance](https://code.claude.com/docs/en/slash-commands).

## License

MIT
