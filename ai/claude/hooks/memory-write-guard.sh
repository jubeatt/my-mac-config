#!/usr/bin/env bash
# PreToolUse guard: ask the user before Claude writes to auto-memory directories
# (~/.claude/projects/*/memory/). Covers file-editing tools and Bash commands
# that reference a memory path.

input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")

target=""
case "$tool" in
  Write | Edit | MultiEdit | NotebookEdit)
    target=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input")
    [[ "$target" == */.claude/projects/*/memory/* ]] || exit 0
    ;;
  Bash)
    target=$(jq -r '.tool_input.command // empty' <<<"$input")
    grep -qE '\.claude/projects/[^[:space:]]*/memory' <<<"$target" || exit 0
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
