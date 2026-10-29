#!/bin/bash
# Notification hook
# 通知コマンドが OS ごとに異なり、どちらも無い環境で hook エラーを出さないよう存在確認してから呼ぶ。

set -uo pipefail

cat >/dev/null

title='Claude Code sent notification'
message="${CLAUDE_PROJECT_DIR:-}"

if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier -title "$title" -message "$message" -sound default
elif command -v notify-send >/dev/null 2>&1; then
  notify-send "$title" "$message"
fi
exit 0
