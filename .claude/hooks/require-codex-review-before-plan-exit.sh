#!/bin/bash
# PreToolUse hook for ExitPlanMode
# codex review の反復が完了し、指摘ゼロになるまでプラン確定をブロックする
#
# 判定ロジック:
#   transcript に CODEX_PLAN_REVIEW_PASSED マーカーがあれば通す。
#   マーカーは Claude が codex review の指摘ゼロを確認した後に echo する。

set -euo pipefail

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path')

if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

if grep -q 'CODEX_PLAN_REVIEW_PASSED' "$TRANSCRIPT" 2>/dev/null; then
  exit 0
fi

cat >&2 <<'MSG'
ExitPlanMode blocked: codex review による反復レビューが未完了です。

以下のワークフローに従ってください:

1. プランファイルの内容を codex review に渡す
     cat <plan-file-path> | codex review -
2. codex review の出力を確認する
3. 指摘がある場合:
   a. 指摘内容を精査する（鵜呑みにせず、コードベースを確認して総合判断する）
   b. 妥当な指摘はプランファイルに反映する
   c. 不明な点はユーザーにヒアリングする（AskUserQuestion）
   d. 再度 codex review を実行する（手順1に戻る）
4. 指摘がなくなったら、以下のマーカーコマンドを実行する:
     echo CODEX_PLAN_REVIEW_PASSED
5. その後 ExitPlanMode を呼ぶ

注意:
- ユーザーにはプランの中間状態を見せる必要はない
- マーカーは codex review の指摘がゼロになった場合のみ実行すること
MSG
exit 2
