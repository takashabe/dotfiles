#!/usr/bin/env bash

set -euo pipefail

# Count sidebar panes marked by tmux-agent-sidebar (@pane_role=sidebar)
sidebar_count=$(tmux list-panes -F '#{@pane_role}' | grep -c '^sidebar$' || true)
pane_count=$(tmux list-panes | wc -l)
work_pane_count=$((pane_count - sidebar_count))

if [ "$work_pane_count" -eq 1 ]; then
  # Find the main (non-sidebar) pane and create IDE layout
  main_pane=$(tmux list-panes -F '#{pane_id}|#{@pane_role}' | grep -v '|sidebar$' | head -1 | cut -d'|' -f1)
  tmux split-window -v -l 30% -t "$main_pane"
  tmux split-window -h
elif [ "$work_pane_count" -eq 3 ]; then
  # Find the bottom-left pane (2nd non-sidebar pane) and adjust size
  bottom_left_pane=$(tmux list-panes -F '#{pane_id}|#{@pane_role}' | grep -v '|sidebar$' | sed -n '2p' | cut -d'|' -f1)
  tmux select-pane -t "$bottom_left_pane"
  tmux resize-pane -y 30%
fi

# Resize sidebar to 15% width
sidebar_pane=$(tmux list-panes -F '#{pane_id}|#{@pane_role}' | grep '|sidebar$' | cut -d'|' -f1)
if [ -n "$sidebar_pane" ]; then
  tmux resize-pane -t "$sidebar_pane" -x 15%
fi
