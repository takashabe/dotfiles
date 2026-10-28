#!/bin/bash
# PreToolUse hook for Bash
# push の安全弁はグローバルな git pre-push hook（~/dotfiles/.config/git/hooks/pre-push）に
# 置いている。ここではその hook を迂回する形と、PR のマージだけを止める。
# コマンド文字列の解釈は原理的に穴が尽きないので、見る形を最小限に絞っている。

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

block() {
  cat >&2 <<MSG
Bash blocked: $1

対象コマンド: $COMMAND
MSG
  exit 2
}

if printf '%s\n' "$COMMAND" | grep -Eiq 'hookspath'; then
  block "core.hooksPath の変更・上書きは、push の安全弁を無効にするため実行しません"
fi

# pre-push hook は CLAUDECODE でエージェントを見分けるので、この変数に触れる形は通さない
if printf '%s\n' "$COMMAND" | grep -Eq 'CLAUDECODE'; then
  block "CLAUDECODE 環境変数の変更・解除は、push の安全弁を無効にするため実行しません"
fi

if printf '%s\n' "$COMMAND" | grep -Eq '(^|[^[:alnum:]_-])git([^[:alnum:]_-]|$)' \
  && printf '%s\n' "$COMMAND" | grep -Eq -e '--no-verify'; then
  block "git --no-verify は pre-push hook を迂回するため実行しません"
fi

if printf '%s\n' "$COMMAND" | grep -Eq '(^|[^[:alnum:]_-])gh[[:space:]]+pr[[:space:]]+merge([^[:alnum:]_-]|$)'; then
  block "gh pr merge はエージェントからは実行しません。マージはユーザーが行います"
fi

exit 0
