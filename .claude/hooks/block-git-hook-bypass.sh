#!/bin/bash
# PreToolUse hook for Bash
# push の安全弁はグローバルな git pre-push hook（~/dotfiles/.config/git/hooks/pre-push）に
# 置いている。ここではその hook を迂回・無効化する形と、PR のマージだけを止める。
# コマンド文字列の解釈は原理的に穴が尽きないので、見る形を限定し、最終的な保証は
# GitHub 側の ruleset に置く前提。ここは多層防御の一枚にすぎない。

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# 引用符・エスケープ・変数展開で語を崩した形も拾うため、先に剥がしてから比較する
NORMALIZED=$(printf '%s\n' "$COMMAND" | tr -d "'\"\\\\\$")

block() {
  cat >&2 <<MSG
Bash blocked: $1

対象コマンド: $COMMAND
MSG
  exit 2
}

matches() { printf '%s\n' "$NORMALIZED" | grep -Eiq -e "$1"; }
has_git() { matches '(^|[^[:alnum:]_-])git([^[:alnum:]_-]|$)'; }

if matches 'hookspath'; then
  block "core.hooksPath の変更・上書きは、push の安全弁を無効にするため実行しません"
fi

if matches 'CLAUDE.?CODE'; then
  block "CLAUDECODE 環境変数の変更・解除は、push の安全弁を無効にするため実行しません"
fi

if matches '(^|[^[:alnum:]_-])(env[[:space:]]+(-[a-zA-Z]*[iu]|--ignore-environment|--unset)|unset[[:space:]]|exec[[:space:]]+-c|su([[:space:]]|$)|setsid[[:space:]])'; then
  block "環境変数を消す・外す形のコマンドは、push の安全弁を無効にできるため実行しません"
fi

# 設定の読み先を差し替えると hooksPath が効かなくなる
if has_git && matches '(^|[^[:alnum:]_])(GIT_CONFIG[A-Z_]*|GIT_DIR|GIT_COMMON_DIR|HOME|XDG_CONFIG_HOME)='; then
  block "git の設定やリポジトリの読み先を差し替える環境変数付きの git は実行しません"
fi

if has_git && matches '[-][-]no-v'; then
  block "git --no-verify は pre-push hook を迂回するため実行しません"
fi

if matches '(^|[^[:alnum:]_-])git([[:space:]]+[^[:space:]|;&]+)*[[:space:]]+(send-pack|receive-pack|update-ref)([^[:alnum:]_-]|$)'; then
  block "git send-pack / update-ref などの低レベル操作は pre-push hook を通らないため実行しません"
fi

if matches '(^|[^[:alnum:]_-])gh([[:space:]]+[^[:space:]|;&]+)*[[:space:]]+pr[[:space:]]+merge([^[:alnum:]_-]|$)' \
  || matches '(^|[^[:alnum:]_-])gh([[:space:]]+[^[:space:]|;&]+)*[[:space:]]+api[^|;&]*/(pulls/[^/[:space:]]+/merge|git/refs)'; then
  block "PR のマージと refs の直接更新はエージェントからは実行しません。マージはユーザーが行います"
fi

exit 0
