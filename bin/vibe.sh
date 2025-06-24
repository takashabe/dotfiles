#!/usr/bin/env bash

set -euo pipefail

max_pane=3
pane_count=$(tmux list-panes | wc -l)

[ $pane_count -gt $max_pane ] && { echo "エラー: pane数が多すぎます（$pane_count > $max_pane）"; exit 1; }

[ $pane_count -eq $max_pane ] || {
  # 5pane未満なら不足分を作成
  [ $pane_count -eq 1 ] && tmux split-window -h -p 50
  tmux select-pane -t 1
  for ((i=pane_count; i<$max_pane-1; i++)); do
    tmux split-window -v
  done
}

# レイアウト調整
tmux select-pane -t 0 && tmux resize-pane -x 50%
for ((i=1; i<$max_pane; i++)); do
  tmux select-pane -t $i && tmux resize-pane -y 50%
done
tmux select-pane -t 0
