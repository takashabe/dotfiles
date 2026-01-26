#!/bin/bash
ZJ_SESSIONS=$(zellij list-sessions -n -s)
[ -z "$ZJ_SESSIONS" ] && echo "No other sessions found." && exit 0
SELECTED_SESSION=$(echo "$ZJ_SESSIONS" | fzf --reverse --header "Select Session" --height=100%)
[ -n "$SELECTED_SESSION" ] && zellij action attach "$SELECTED_SESSION"
