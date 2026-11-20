#!/usr/bin/env bash
# PreToolUse guard: ask the user before Claude writes to auto-memory directories
# (~/.claude/projects/*/memory/). Covers file-editing tools and Bash commands
# that reference a memory path, letting read-only Bash commands through.

input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")

read_only_bash() {
  local cmd=$1 segment word rest
  # shellcheck disable=SC2016
  [[ "$cmd" == *'$('* || "$cmd" == *'`'* ]] && return 1
  cmd=$(sed -E 's/[0-9&]*>+[[:space:]]*\/dev\/null//g; s/[0-9]*>&[0-9-]+//g' <<<"$cmd")
  [[ "$cmd" == *'>'* ]] && return 1
  while IFS= read -r segment; do
    read -r word rest <<<"$segment"
    case "$word" in
      '' | cat | head | tail | less | ls | grep | rg | fd | wc | stat | file | diff | tree | bat | jq | sort | uniq | cut | tr | echo | printf | cd | pwd | basename | dirname | realpath | readlink) ;;
      sed) grep -qE '(^|[[:space:]])(-[a-zA-Z]*i|--in-place)' <<<"$rest" && return 1 ;;
      find) grep -qE '(^|[[:space:]])-(delete|exec|execdir|ok|okdir|fprint|fprint0|fprintf|fls)([[:space:]]|$)' <<<"$rest" && return 1 ;;
      *) return 1 ;;
    esac
  done < <(tr '|;&' '\n' <<<"$cmd")
  return 0
}

target=""
case "$tool" in
  Write | Edit | MultiEdit | NotebookEdit)
    target=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input")
    [[ "$target" == */.claude/projects/*/memory/* ]] || exit 0
    ;;
  Bash)
    target=$(jq -r '.tool_input.command // empty' <<<"$input")
    grep -qE '\.claude/projects/[^[:space:]]*/memory' <<<"$target" || exit 0
    read_only_bash "$target" && exit 0
    ;;
  *)
    exit 0
    ;;
esac

jq -n --arg tool "$tool" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: ("Claude wants to modify memory via " + $tool + " — confirm before writing.")
  }
}'
