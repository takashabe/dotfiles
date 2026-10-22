#!/usr/bin/env bash

set -euo pipefail

if [ -z "${TMUX:-}" ] || [ -z "${TMUX_PANE:-}" ]; then
  echo "tmux の中で実行してください" >&2
  exit 1
fi

# kill-pane -a だと tmux-agent-sidebar のペインまで閉じてしまうため、サイドバーは残す
tmux list-panes -t "$TMUX_PANE" -F '#{pane_id} #{@pane_role}' |
  while read -r pane_id role; do
    if [ "$pane_id" != "$TMUX_PANE" ] && [ "$role" != "sidebar" ]; then
      tmux kill-pane -t "$pane_id"
    fi
  done

exec "$(dirname "$0")"/ide.sh
