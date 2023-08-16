#!/usr/bin/env bash

set -euo pipefail

pane_count=$(tmux list-panes | wc -l)

if [ $pane_count -eq 1 ]; then
  # ウィンドウの1/3の幅を計算
  width=$(tmux display-message -p '#{window_width}')
  one_third=$((width / 3))

  # ウィンドウを3分割
  tmux split-window -h
  tmux split-window -h

  # 3つのペインの幅を設定
  tmux resize-pane -t 0 -x $one_third
  tmux resize-pane -t 1 -x $one_third
  tmux resize-pane -t 2 -x $one_third
fi
