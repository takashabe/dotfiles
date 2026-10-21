#!/usr/bin/env bash

set -euo pipefail

top_ratio=0.7

tmux_ide() {
  # Count sidebar panes marked by tmux-agent-sidebar (@pane_role=sidebar)
  local sidebar_count pane_count work_pane_count
  sidebar_count=$(tmux list-panes -F '#{@pane_role}' | grep -c '^sidebar$' || true)
  pane_count=$(tmux list-panes | wc -l)
  work_pane_count=$((pane_count - sidebar_count))

  if [ "$work_pane_count" -eq 1 ]; then
    # Find the main (non-sidebar) pane and create IDE layout
    local main_pane
    main_pane=$(tmux list-panes -F '#{pane_id}|#{@pane_role}' | grep -v '|sidebar$' | head -1 | cut -d'|' -f1)
    tmux split-window -v -l 30% -t "$main_pane"
    tmux split-window -h
  elif [ "$work_pane_count" -eq 3 ]; then
    # Find the bottom-left pane (2nd non-sidebar pane) and adjust size
    local bottom_left_pane
    bottom_left_pane=$(tmux list-panes -F '#{pane_id}|#{@pane_role}' | grep -v '|sidebar$' | sed -n '2p' | cut -d'|' -f1)
    tmux select-pane -t "$bottom_left_pane"
    tmux resize-pane -y 30%
  fi

  # Resize sidebar to 15% width
  local sidebar_pane
  sidebar_pane=$(tmux list-panes -F '#{pane_id}|#{@pane_role}' | grep '|sidebar$' | cut -d'|' -f1)
  if [ -n "$sidebar_pane" ]; then
    tmux resize-pane -t "$sidebar_pane" -x 15%
  fi
}

herdr_ide() {
  local layout pane_count
  layout=$(herdr pane layout --current)
  pane_count=$(jq '.result.layout.panes | length' <<<"$layout")

  if [ "$pane_count" -eq 1 ]; then
    local main_pane bottom_pane
    main_pane=$(jq -r '.result.layout.panes[0].pane_id' <<<"$layout")
    bottom_pane=$(herdr pane split --pane "$main_pane" --direction down --ratio "$top_ratio" --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id')
    herdr pane split --pane "$bottom_pane" --direction right --ratio 0.5 --cwd "$PWD" --no-focus >/dev/null
  elif [ "$pane_count" -eq 3 ]; then
    local root_ratio bottom_left_pane delta
    root_ratio=$(jq -r '
      .result.layout as $l
      | $l.splits[]
      | select(.direction == "down" and .rect == $l.area)
      | .ratio
    ' <<<"$layout")
    if [ -z "$root_ratio" ]; then
      return 0
    fi
    bottom_left_pane=$(jq -r '.result.layout.panes | max_by(.rect.y, -.rect.x) | .pane_id' <<<"$layout")
    delta=$(jq -n --argjson r "$root_ratio" --argjson t "$top_ratio" '$t - $r')
    if jq -en --argjson d "$delta" '$d > 0' >/dev/null; then
      herdr pane resize --pane "$bottom_left_pane" --direction down --amount "$delta" >/dev/null
    elif jq -en --argjson d "$delta" '$d < 0' >/dev/null; then
      herdr pane resize --pane "$bottom_left_pane" --direction up --amount "$(jq -n --argjson d "$delta" '-$d')" >/dev/null
    fi
  fi
}

if [ "${HERDR_ENV:-}" = "1" ]; then
  herdr_ide
elif [ -n "${TMUX:-}" ]; then
  tmux_ide
else
  echo "tmux または herdr の中で実行してください" >&2
  exit 1
fi
