#!/usr/bin/env bash

set -euo pipefail

if [ "${HERDR_ENV:-}" != "1" ]; then
  echo "herdr の外では実行できません" >&2
  exit 1
fi

top_ratio=0.7

layout=$(herdr pane layout --current)
pane_count=$(jq '.result.layout.panes | length' <<<"$layout")

if [ "$pane_count" -eq 1 ]; then
  main_pane=$(jq -r '.result.layout.panes[0].pane_id' <<<"$layout")
  bottom_pane=$(herdr pane split --pane "$main_pane" --direction down --ratio "$top_ratio" --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id')
  herdr pane split --pane "$bottom_pane" --direction right --ratio 0.5 --cwd "$PWD" --no-focus >/dev/null
elif [ "$pane_count" -eq 3 ]; then
  root_ratio=$(jq -r '
    .result.layout as $l
    | $l.splits[]
    | select(.direction == "down" and .rect == $l.area)
    | .ratio
  ' <<<"$layout")
  if [ -z "$root_ratio" ]; then
    exit 0
  fi
  bottom_left_pane=$(jq -r '.result.layout.panes | max_by(.rect.y, -.rect.x) | .pane_id' <<<"$layout")
  delta=$(jq -n --argjson r "$root_ratio" --argjson t "$top_ratio" '$t - $r')
  if jq -en --argjson d "$delta" '$d > 0' >/dev/null; then
    herdr pane resize --pane "$bottom_left_pane" --direction down --amount "$delta" >/dev/null
  elif jq -en --argjson d "$delta" '$d < 0' >/dev/null; then
    herdr pane resize --pane "$bottom_left_pane" --direction up --amount "$(jq -n --argjson d "$delta" '-$d')" >/dev/null
  fi
fi
