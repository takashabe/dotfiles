#!/bin/bash
# PreToolUse hook for Bash
# settings.json の attribution を空にしても、モデルが学習時の癖で Co-Authored-By trailer や
# 「Generated with Claude Code」を自発的に書き足すことがあるため、決定論的に止める。
#
# -F / --body-file 経由でファイルから渡すメッセージは検査しない。

set -euo pipefail

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# grep や git log --grep で trailer を検索するだけのコマンドを巻き込まないよう、書き込み系に限定する。
printf '%s\n' "$COMMAND" | grep -Eq '(^|[^[:alnum:]_-])(git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit|gh[[:space:]]+pr[[:space:]]+(create|edit|comment|merge))([^[:alnum:]_-]|$)' || exit 0

printf '%s\n' "$COMMAND" | grep -Eiq 'co-authored-by:[^\n]*(claude|anthropic)|noreply@anthropic\.com|generated with \[?claude code' || exit 0

cat >&2 <<'MSG'
Bash blocked: コミットメッセージまたは PR 本文に Claude の attribution が含まれています。

Co-Authored-By: Claude ... <noreply@anthropic.com> や「Generated with Claude Code」は付けない方針です。
これらの行を取り除いて、同じコマンドを再実行してください。
MSG
exit 2
