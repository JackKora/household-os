#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [--data-dir PATH]
  --data-dir PATH  Install there without prompting

Without --data-dir, interactive installs prompt using $HOUSEHOLD_OS_DATA_DIR or
~/household-os-data. Noninteractive installs require --data-dir or an exported
HOUSEHOLD_OS_DATA_DIR; shell startup files are not read.
EOF
}

die() { printf 'Error: %s\n' "$1" >&2; exit 1; }

absolute() {
  local p=$1 part prefix suffix= physical
  local -a parts=() raw=()
  case "$p" in
    '~') p=$HOME ;;
    '~/'*) p="$HOME/${p#\~/}" ;;
    '~'*) die "unsupported home-directory form: $p" ;;
  esac
  case "$p" in /*) ;; *) p="$PWD/$p" ;; esac
  IFS=/ read -r -a raw <<< "$p"
  for part in "${raw[@]}"; do
    case "$part" in ''|.) ;; ..) [ "${#parts[@]}" -gt 0 ] && unset 'parts[${#parts[@]}-1]' ;; *) parts+=("$part") ;; esac
  done
  p=/
  for part in "${parts[@]}"; do p=${p%/}/$part; done
  prefix=$p
  while [ ! -e "$prefix" ] && [ ! -L "$prefix" ]; do
    part=${prefix##*/}
    suffix="/$part$suffix"
    prefix=${prefix%/*}
    [ -n "$prefix" ] || prefix=/
  done
  if [ -d "$prefix" ]; then
    physical=$(CDPATH= cd -- "$prefix" && pwd -P)
    printf '%s%s\n' "$physical" "$suffix"
  else
    printf '%s\n' "$p"
  fi
}

below() { [ "$1" = "$2" ] || [[ "$1" == "$2"/* ]]; }
okdir() { [ ! -L "$1" ] && { [ ! -e "$1" ] || [ -d "$1" ]; }; }
okfile() { [ ! -L "$1" ] && { [ ! -e "$1" ] || [ -f "$1" ]; }; }

data=
explicit=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --data-dir)
      [ "$#" -gt 1 ] && [ -n "$2" ] || die '--data-dir requires a path'
      data=$2
      explicit=1
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "${HOME:-}" ] || die 'HOME is required'
if [ "$explicit" = 0 ]; then
  data=${HOUSEHOLD_OS_DATA_DIR:-$HOME/household-os-data}
  if [ -t 0 ]; then
    printf 'Household OS data directory [%s]: ' "$data"
    IFS= read -r answer
    [ -z "$answer" ] || data=$answer
  elif [ -z "${HOUSEHOLD_OS_DATA_DIR:-}" ]; then
    die 'noninteractive installation requires --data-dir or exported HOUSEHOLD_OS_DATA_DIR'
  fi
fi

umask 077
logic=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
templates=$logic/templates/data
data=$(absolute "$data")
home=$(absolute "$HOME")
[ "$data" != / ] || die 'the data directory cannot be /'
[ "$data" != "$home" ] || die 'the data directory cannot be HOME itself'
below "$data" "$logic" && die 'the data directory cannot be the public logic repository or its descendant'
[ ! -L "$data" ] || die 'the data directory cannot be a symlink'
command -v git >/dev/null || die 'git is required'

existing=0
state=$data/.household-os/logic-root
if [ -e "$data" ]; then
  [ -d "$data" ] || die 'the data directory is not a directory'
  if [ -n "$(find "$data" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    [ -f "$state" ] && [ ! -L "$state" ] || die 'refusing an unrecognized nonempty directory'
    existing=1
  fi
fi
parent=$data
while [ ! -d "$parent" ]; do parent=${parent%/*}; [ -n "$parent" ] || parent=/; done
if [ "$existing" = 1 ]; then
  [ -d "$data/.git" ] && [ ! -L "$data/.git" ] || die 'recognized data repositories require a normal .git directory'
  top=$(git -C "$data" rev-parse --show-toplevel 2>/dev/null) || die 'invalid Git metadata'
  [ "$(absolute "$top")" = "$data" ] || die 'Git top level must equal the data directory'
  outer=${data%/*}; [ -n "$outer" ] || outer=/
  if outer_top=$(git -C "$outer" rev-parse --show-toplevel 2>/dev/null); then die "refusing a data repository nested inside $outer_top"; fi
elif outer_top=$(git -C "$parent" rev-parse --show-toplevel 2>/dev/null); then
  die "refusing to create a nested Git repository inside $outer_top"
fi

files=(CLAUDE.md README.md gitignore shared/household.md modules/financial-advisor/profile.md modules/financial-advisor/goals.md modules/financial-advisor/accounts.md modules/financial-advisor/properties.md modules/general-contractor/property.md modules/legal-advisor/profile.md modules/parenting/child.md modules/parenting/family.md modules/parenting/current-context.md modules/political-advisor/profile.md modules/wellness-coach/profile.md modules/wellness-coach/goals.md modules/wellness-coach/health.md modules/wellness-coach/notion.md)
for f in "${files[@]}"; do
  dest=$data/$f
  [ "$f" = gitignore ] && dest=$data/.gitignore
  okfile "$dest" || die "expected a regular file at $dest"
  dir=$(dirname "$dest")
  while [ "$dir" != "$data" ]; do okdir "$dir" || die "expected a directory at $dir"; dir=$(dirname "$dir"); done
done
for d in "$data/.household-os" "$data/.agents" "$data/.agents/skills" "$data/.claude" "$data/.claude/skills"; do
  okdir "$d" || die "expected a directory at $d"
done
if [ "$existing" = 1 ]; then
  [ -f "$data/CLAUDE.md" ] && [ ! -L "$data/CLAUDE.md" ] || die 'existing CLAUDE.md must be regular'
  cmp -s "$templates/CLAUDE.md" "$data/CLAUDE.md" || die "existing CLAUDE.md was preserved; reconcile it with $templates/CLAUDE.md before rerunning"
  IFS= read -r previous < "$state" || previous=
else
  previous=
fi
for skill in financial-advisor general-contractor legal-advisor parenting political-advisor wellness-coach; do
  for base in .agents .claude; do
    link=$data/$base/skills/$skill
    target=$logic/skills/$skill
    if [ -L "$link" ]; then
      current=$(readlink "$link")
      { [ "$current" = "$target" ] || { [ -n "$previous" ] && [ "$current" = "$previous/skills/$skill" ]; }; } || die "unmanaged skill link: $link"
    elif [ -e "$link" ]; then die "unmanaged skill path: $link"; fi
  done
done
if [ -L "$data/AGENTS.md" ]; then [ "$(readlink "$data/AGENTS.md")" = CLAUDE.md ] || die 'unmanaged AGENTS.md link'; elif [ -e "$data/AGENTS.md" ]; then die 'unmanaged AGENTS.md'; fi
if [ "$existing" = 1 ]; then okdir "$data/.git/info" || die 'invalid Git info directory'; okfile "$data/.git/info/exclude" || die 'invalid Git exclude file'; fi

mkdir -p "$data/.household-os" "$data/.agents/skills" "$data/.claude/skills"
[ "$existing" = 1 ] || chmod 700 "$data"
for f in "${files[@]}"; do
  src=$templates/$f; dest=$data/$f
  [ "$f" = gitignore ] && dest=$data/.gitignore
  mkdir -p "$(dirname "$dest")"
  [ -e "$dest" ] || cp "$src" "$dest"
done
for skill in financial-advisor general-contractor legal-advisor parenting political-advisor wellness-coach; do
  for base in .agents .claude; do
    link=$data/$base/skills/$skill; target=$logic/skills/$skill
    if [ -L "$link" ] && [ "$(readlink "$link")" != "$target" ]; then unlink "$link"; fi
    [ -e "$link" ] || ln -s "$target" "$link"
  done
done
[ -e "$data/AGENTS.md" ] || ln -s CLAUDE.md "$data/AGENTS.md"
[ "$existing" = 1 ] || git init -q "$data"
printf '%s\n' "$logic" > "$state"
exclude=$data/.git/info/exclude
touch "$exclude"
for e in .household-os/ .agents/skills/ .claude/skills/; do grep -F -x -q "$e" "$exclude" || printf '%s\n' "$e" >> "$exclude"; done
printf 'Household OS is ready.\nData repository: %s\n' "$data"
