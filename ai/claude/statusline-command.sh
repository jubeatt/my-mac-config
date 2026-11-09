#!/usr/bin/env bash
# Claude Code status line, styled after the Codex footer:
#   <model> <effort> · <cwd> · Context N% left · <branch> · <git state>

input=$(cat)

j() { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }

model=$(j '.model.display_name')
model_id=$(j '.model.id')
cwd=$(j '.workspace.current_dir')
[ -z "$cwd" ] && cwd=$(j '.cwd')
[ -z "$cwd" ] && cwd=$PWD

# Effort: prefer the value passed in, fall back to settings.json
effort=$(j '.effort.level // .effort // .model.effort')
if [ -z "$effort" ] && [ -n "$model_id" ] && [ -f "$HOME/.claude/settings.json" ]; then
  effort=$(jq -r --arg m "$model_id" \
    '.modelSettings[$m].effortLevel // .effortLevel // empty' \
    "$HOME/.claude/settings.json" 2>/dev/null)
fi

# Context remaining
ctx=$(j '.context_window.remaining_percentage')
if [ -z "$ctx" ]; then
  used=$(j '.context_window.used_percentage')
  [ -n "$used" ] && ctx=$((100 - ${used%.*}))
fi
[ -n "$ctx" ] && ctx="${ctx%.*}"

# Git info (skip optional locks so we never block other git commands)
branch=""
state=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  # Lines added/removed vs HEAD (staged + unstaged)
  read -r added removed < <(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" diff HEAD --numstat 2>/dev/null \
    | awk '{a+=$1; d+=$2} END {print a+0, d+0}')
  if [ "${added:-0}" -eq 0 ] && [ "${removed:-0}" -eq 0 ]; then
    state="No changes"
  else
    state="+${added} -${removed}"
  fi
fi

# Truecolor palette (pastel on dark background)
rgb() { printf '\e[38;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
bold=$'\e[1m'
text=$(rgb cdd6f4)
muted=$(rgb 7f849c)
green=$(rgb a6e3a1)
peach=$(rgb fab387)
blue=$(rgb 89b4fa)
red=$(rgb f38ba8)
reset=$'\e[0m'
sep=" ${muted}·${reset} "

line="${bold}${text}${model:-Claude}${reset}"
[ -n "$effort" ] && line+=" ${text}${effort}${reset}"
line+="${sep}${green}${cwd/#$HOME/~}${reset}"

# Context turns red when running low
if [ -n "$ctx" ]; then
  ctx_color=$peach
  [ "$ctx" -le 20 ] && ctx_color=$red
  line+="${sep}${ctx_color}Context ${ctx}% left${reset}"
fi

[ -n "$branch" ] && line+="${sep}${blue}${branch}${reset}"
if [ -n "$state" ]; then
  if [ "$state" = "No changes" ]; then
    line+="${sep}${blue}${state}${reset}"
  else
    line+="${sep}${green}+${added}${reset} ${red}-${removed}${reset}"
  fi
fi

printf '%s\n' "$line"
