#!/usr/bin/env bash

set -euo pipefail

pane_count=$(tmux list-panes | wc -l)

if [ $pane_count -eq 1 ]; then
  # If there is only 1 pane, create 2 panes at the bottom.
  tmux split-window -v -p 25
  tmux split-window -h
elif [ $pane_count -eq 3 ]; then
  # If there are already 3 panes, adjust the size of the bottom panes.
  tmux select-pane -t 1
  tmux resize-pane -y 25
fi
