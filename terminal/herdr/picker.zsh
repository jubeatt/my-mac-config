#!/usr/bin/env zsh
# Arrow-key picker for a Herdr popup: Enter focuses the selected agent or space.
# Usage: picker.zsh agents|spaces
emulate -L zsh

spaces_json=$("$HERDR_BIN_PATH" workspace list)

if [[ $1 == spaces ]]; then
  focus_command=(workspace focus)
  current_id=${HERDR_ACTIVE_WORKSPACE_ID:-}
  label_width=40
  rows=$(jq -r '
    def count($n; $noun): "\($n) \($noun)\(if $n == 1 then "" else "s" end)";
    .result.workspaces[]
    | [.workspace_id, .label, count(.tab_count; "tab"), .agent_status, count(.pane_count; "pane")]
    | @tsv' <<< "$spaces_json")
else
  focus_command=(agent focus)
  current_id=${HERDR_ACTIVE_PANE_ID:-}
  label_width=16
  rows=$(jq -rn --argjson spaces "$spaces_json" --argjson agents "$("$HERDR_BIN_PATH" agent list)" '
    def attention: {blocked: 0, done: 1, working: 2, idle: 3}[.agent_status] // 4;
    ($spaces.result.workspaces | map({(.workspace_id): .label}) | add) as $labels
    | $agents.result.agents
    | sort_by(attention)[]
    | [.pane_id, $labels[.workspace_id], .agent, .agent_status, (.terminal_title_stripped // "")]
    | @tsv')
fi

items=("${(@f)rows}")
items=(${items:#})
item_count=${#items}

if (( item_count == 0 )); then
  print "Nothing to select"
  sleep 1
  exit 0
fi

id_at() { print -r -- "${items[$1]%%$'\t'*}" }

selected=1
for (( i = 1; i <= item_count; i++ )); do
  if [[ $(id_at $i) == "$current_id" ]]; then
    selected=$i
    break
  fi
done

terminal_size=(${=$(stty size)})
terminal_cols=${terminal_size[2]}
list_rows=$(( terminal_size[1] - 2 ))
tail_width=$(( terminal_cols - label_width - 21 ))
typeset -A state_colors=(blocked 31 working 33 done 32 idle 90 unknown 35)

render() {
  local -a fields
  local frame='' row='' columns='' state=''
  local first=$(( selected > list_rows ? selected - list_rows + 1 : 1 ))
  local last=$(( first + list_rows - 1 ))
  (( last > item_count )) && last=$item_count
  local line=1
  for (( i = first; i <= last; i++ )); do
    fields=("${(@ps:\t:)items[$i]}")
    columns="${(mr:$label_width:: :)fields[2]} ${(mr:8:: :)fields[3]} "
    state=${(mr:8:: :)fields[4]}
    row=" ${(mr:$tail_width:: :)fields[5]}"
    frame+=$'\e['$line$';1H'
    if (( i == selected )); then
      frame+=$'\e[1;7m❯ '$columns$state$row$'\e[0m'
    else
      frame+="  $columns"$'\e['${state_colors[${fields[4]}]:-0}m$state$'\e[0m'$row
    fi
    (( line++ ))
  done
  frame+=$'\e['$(( line + 1 ))$';1H\e[2m↑/↓ select   enter go   esc cancel\e[0m\e[J'
  print -n -- '\e[?25l'
  print -rn -- "$frame"
}

move() {
  selected=$(( (selected - 1 + $1 + item_count) % item_count + 1 ))
}

while true; do
  render
  read -s -k 1 key || break
  if [[ $key == $'\e' ]]; then
    rest=""
    read -s -t 0.02 -k 2 rest || rest=""
    key+=$rest
  fi
  case $key in
    $'\e[A'|$'\eOA') move -1 ;;
    $'\e[B'|$'\eOB') move 1 ;;
    $'\n'|$'\r')
      "$HERDR_BIN_PATH" $focus_command "$(id_at $selected)" >/dev/null 2>&1
      exit 0
      ;;
    $'\e') exit 0 ;;
  esac
done
