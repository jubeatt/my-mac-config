#!/usr/bin/env bash
# Claude Code status line: <branch> · <context tokens>

input=$(cat)

cwd=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input" 2>/dev/null)
[ -z "$cwd" ] && cwd=$PWD

# current_usage is null at session start and right after /compact.
tokens=$(jq -r '
  .context_window.current_usage
  | if . == null then empty
    else (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)
    end
' <<<"$input" 2>/dev/null)
pct=$(jq -r '.context_window.used_percentage // empty' <<<"$input" 2>/dev/null)

# GIT_OPTIONAL_LOCKS=0 keeps this from blocking concurrent git commands.
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
  || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

rgb() { printf '\e[38;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
muted=$(rgb 7f849c)
blue=$(rgb 89b4fa)
green=$(rgb a6e3a1)
yellow=$(rgb f9e2af)
red=$(rgb f38ba8)
bold=$'\e[1m'
reset=$'\e[0m'

parts=()
[ -n "$branch" ] && parts+=("${blue}${branch}${reset}")

if [ -n "$tokens" ] && [ "$tokens" -gt 0 ]; then
  if [ "$tokens" -ge 150000 ]; then color=$red
  elif [ "$tokens" -ge 80000 ]; then color=$yellow
  else color=$green
  fi
  ctx="${bold}${color}$(awk -v t="$tokens" 'BEGIN { printf "%.1fk", t / 1000 }')${reset}"
  [ -n "$pct" ] && ctx+=" ${muted}($(awk -v p="$pct" 'BEGIN { printf "%.1f%%", p }'))${reset}"
  parts+=("$ctx")
fi

sep=" ${muted}·${reset} "
line=""
for p in "${parts[@]}"; do
  [ -n "$line" ] && line+="$sep"
  line+="$p"
done

printf '%s\n' "$line"
