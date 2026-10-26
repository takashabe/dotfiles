#!/usr/bin/env bash

set -euo pipefail

# Count sidebar panes marked by tmux-agent-sidebar (@pane_role=sidebar)
sidebar_count=$(tmux list-panes -F '#{@pane_role}' | grep -c '^sidebar$' || true)
pane_count=$(tmux list-panes | wc -l)
work_pane_count=$((pane_count - sidebar_count))

if [ "$work_pane_count" -ne 1 ] && [ "$work_pane_count" -ne 3 ]; then
  exit 0
fi

# 作業領域の幅が sidebar の幅に依存するため、先に sidebar を確定させる
sidebar_pane=$(tmux list-panes -F '#{pane_id}|#{@pane_role}' | grep '|sidebar$' | cut -d'|' -f1 || true)
if [ -n "$sidebar_pane" ]; then
  tmux resize-pane -t "$sidebar_pane" -x 15%
fi

if [ "$work_pane_count" -eq 1 ]; then
  main_pane=$(tmux list-panes -F '#{pane_id}|#{@pane_role}' | grep -v '|sidebar$' | cut -d'|' -f1)
  middle_pane=$(tmux split-window -h -t "$main_pane" -P -F '#{pane_id}')
  tmux split-window -h -t "$middle_pane"
fi

work_panes=$(tmux list-panes -F '#{pane_left} #{pane_top} #{pane_right} #{pane_id} #{@pane_role}' | grep -v ' sidebar$' | sort -n)

# 上下分割を含む 3 ペイン構成を崩さないため、横一列のときだけ揃える
if [ "$(awk '{print $2}' <<<"$work_panes" | sort -u | wc -l)" -ne 1 ]; then
  exit 0
fi

work_left=$(head -1 <<<"$work_panes" | awk '{print $1}')
work_right=$(tail -1 <<<"$work_panes" | awk '{print $3}')
# 3 ペイン間の境界線 2 本分を除いて 3 等分する
one_third=$(((work_right - work_left + 1 - 2) / 3))

head -2 <<<"$work_panes" | awk '{print $4}' | while read -r pane_id; do
  tmux resize-pane -t "$pane_id" -x "$one_third"
done
