#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Install Household OS project-scoped skills and private data templates.

Usage:
  ./install.sh [--data-dir PATH]

Options:
  --data-dir PATH  Data repository location (default: ~/household-os-data)
  -h, --help       Show this help
EOF
}

data_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --data-dir)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        printf 'Error: --data-dir requires a path.\n' >&2
        exit 2
      fi
      data_dir=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Error: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

logic_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
template_root="$logic_root/templates/data"

if [ -z "$data_dir" ]; then
  data_dir="${HOME:?HOME is required}/household-os-data"
elif [ "${data_dir#/}" = "$data_dir" ]; then
  data_dir="$PWD/$data_dir"
fi

if [ ! -d "$template_root" ]; then
  printf 'Error: data templates are missing from %s.\n' "$template_root" >&2
  exit 1
fi

mkdir -p \
  "$data_dir/.household-os" \
  "$data_dir/.agents/skills" \
  "$data_dir/.claude/skills" \
  "$data_dir/shared" \
  "$data_dir/modules/financial-advisor/tax" \
  "$data_dir/modules/parenting" \
  "$data_dir/modules/wellness-coach"

install_if_missing() {
  source_file=$1
  destination_file=$2

  if [ ! -e "$destination_file" ] && [ ! -L "$destination_file" ]; then
    cp "$source_file" "$destination_file"
  fi
}

install_if_missing "$template_root/README.md" "$data_dir/README.md"
install_if_missing "$template_root/CLAUDE.md" "$data_dir/CLAUDE.md"
install_if_missing "$template_root/gitignore" "$data_dir/.gitignore"
install_if_missing "$template_root/shared/household.md" "$data_dir/shared/household.md"
install_if_missing "$template_root/modules/financial-advisor/profile.md" "$data_dir/modules/financial-advisor/profile.md"
install_if_missing "$template_root/modules/financial-advisor/goals.md" "$data_dir/modules/financial-advisor/goals.md"
install_if_missing "$template_root/modules/financial-advisor/accounts.md" "$data_dir/modules/financial-advisor/accounts.md"
install_if_missing "$template_root/modules/financial-advisor/properties.md" "$data_dir/modules/financial-advisor/properties.md"
install_if_missing "$template_root/modules/parenting/child.md" "$data_dir/modules/parenting/child.md"
install_if_missing "$template_root/modules/parenting/family.md" "$data_dir/modules/parenting/family.md"
install_if_missing "$template_root/modules/parenting/current-context.md" "$data_dir/modules/parenting/current-context.md"
install_if_missing "$template_root/modules/wellness-coach/profile.md" "$data_dir/modules/wellness-coach/profile.md"
install_if_missing "$template_root/modules/wellness-coach/goals.md" "$data_dir/modules/wellness-coach/goals.md"
install_if_missing "$template_root/modules/wellness-coach/health.md" "$data_dir/modules/wellness-coach/health.md"
install_if_missing "$template_root/modules/wellness-coach/notion.md" "$data_dir/modules/wellness-coach/notion.md"

state_file="$data_dir/.household-os/logic-root"
previous_root=""
if [ -f "$state_file" ]; then
  IFS= read -r previous_root < "$state_file" || true
fi

ensure_skill_link() {
  link_path=$1
  target_path=$2
  skill_name=$3

  if [ -L "$link_path" ]; then
    current_target=$(readlink "$link_path")
    if [ "$current_target" = "$target_path" ]; then
      return
    fi

    if [ -n "$previous_root" ] && [ "$current_target" = "$previous_root/skills/$skill_name" ]; then
      unlink "$link_path"
    else
      printf 'Error: refusing to replace unmanaged symlink %s -> %s.\n' "$link_path" "$current_target" >&2
      exit 1
    fi
  elif [ -e "$link_path" ]; then
    printf 'Error: refusing to replace existing path %s.\n' "$link_path" >&2
    exit 1
  fi

  ln -s "$target_path" "$link_path"
}

ensure_instruction_link() {
  link_path="$data_dir/AGENTS.md"

  if [ -L "$link_path" ]; then
    current_target=$(readlink "$link_path")
    if [ "$current_target" = "CLAUDE.md" ]; then
      return
    fi
    printf 'Error: refusing to replace unmanaged symlink %s -> %s.\n' "$link_path" "$current_target" >&2
    exit 1
  elif [ -e "$link_path" ]; then
    printf 'Error: refusing to replace existing path %s.\n' "$link_path" >&2
    exit 1
  fi

  ln -s "CLAUDE.md" "$link_path"
}

for skill_name in financial-advisor parenting wellness-coach; do
  skill_target="$logic_root/skills/$skill_name"
  if [ ! -f "$skill_target/SKILL.md" ]; then
    printf 'Error: skill is missing: %s\n' "$skill_target" >&2
    exit 1
  fi
  ensure_skill_link "$data_dir/.agents/skills/$skill_name" "$skill_target" "$skill_name"
  ensure_skill_link "$data_dir/.claude/skills/$skill_name" "$skill_target" "$skill_name"
done

ensure_instruction_link

temporary_state="$state_file.tmp"
printf '%s\n' "$logic_root" > "$temporary_state"
mv "$temporary_state" "$state_file"

if [ ! -d "$data_dir/.git" ]; then
  if ! command -v git >/dev/null 2>&1; then
    printf 'Error: git is required to initialize the data repository.\n' >&2
    exit 1
  fi
  git init -q "$data_dir"
fi

printf 'Household OS is ready.\n'
printf 'Data repository: %s\n' "$data_dir"
printf 'Open Codex or Claude Code from that directory, then ask to activate a module or all modules.\n'
