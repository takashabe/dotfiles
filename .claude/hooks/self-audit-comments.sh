#!/usr/bin/env bash
# WHY: 「コメントは WHY のみ」方針が生成時の注意欠落で守られないための補償コントロール。
# Stop ではなく編集直後(PostToolUse)に発火させるのは、focus mode で最終メッセージが
# 監査応答に奪われるのを構造的に防ぎ、タスク遂行の途中でコメントを直させるため。
set -uo pipefail

input=$(cat)

tool=$(jq -r '.tool_name // ""' <<<"$input" 2>/dev/null)
file=$(jq -r '.tool_input.file_path // ""' <<<"$input" 2>/dev/null)
[ -z "$file" ] && exit 0

ext=$(printf '%s' "${file##*.}" | tr 'A-Z' 'a-z')
case "$ext" in
  go|ts|tsx|js|jsx|mjs|cjs|rs|java|kt|kts|c|cc|cpp|h|hpp|swift|scala) style=slash ;;
  sql|lua) style=dash ;;
  py|rb|sh|bash|zsh) style=hash ;;
  *) exit 0 ;;
esac

# 編集で新規に加わったテキストのみを対象にする（既存行や人間の記述を巻き込まない）
added=""
case "$tool" in
  Write)
    added=$(jq -r '.tool_input.content // ""' <<<"$input" 2>/dev/null)
    ;;
  Edit)
    old=$(jq -r '.tool_input.old_string // ""' <<<"$input" 2>/dev/null)
    new=$(jq -r '.tool_input.new_string // ""' <<<"$input" 2>/dev/null)
    added=$(grep -Fxv -f <(printf '%s\n' "$old") <(printf '%s\n' "$new") 2>/dev/null)
    ;;
  MultiEdit)
    n=$(jq -r '.tool_input.edits | length' <<<"$input" 2>/dev/null)
    i=0
    while [ "${n:-0}" -gt 0 ] && [ "$i" -lt "$n" ]; do
      old=$(jq -r ".tool_input.edits[$i].old_string // \"\"" <<<"$input" 2>/dev/null)
      new=$(jq -r ".tool_input.edits[$i].new_string // \"\"" <<<"$input" 2>/dev/null)
      added="$added"$'\n'$(grep -Fxv -f <(printf '%s\n' "$old") <(printf '%s\n' "$new") 2>/dev/null)
      i=$((i+1))
    done
    ;;
  *) exit 0 ;;
esac

[ -z "${added//$'\n'/}" ] && exit 0

comments=$(printf '%s\n' "$added" | awk -v style="$style" '
  { t=$0; sub(/^[[:space:]]+/,"",t); is=0
    if (style=="slash") { if (t ~ /^\/\// || t ~ /^\/\*/ || t ~ /^\*/) is=1 }
    else if (style=="dash") { if (t ~ /^--/) is=1 }
    else if (style=="hash") { if (t ~ /^#/ && t !~ /^#!/) is=1 }
    if (is) print t
  }')
[ -z "$comments" ] && exit 0

# 同一セッションで通知済みのコメント行は除外し、新規のみ報告する（WHY/WHAT は grep で区別できず、
# 正当な WHY コメントを毎編集で蒸し返さないため）
session_id=$(jq -r '.session_id // "unknown"' <<<"$input" 2>/dev/null)
state="${TMPDIR:-/tmp}/claude-self-audit-seen-${session_id}.txt"
touch "$state" 2>/dev/null || true
fresh=$(printf '%s\n' "$comments" | while IFS= read -r line; do
  [ -z "$line" ] && continue
  sig=$(printf '%s|%s' "$file" "$line" | shasum 2>/dev/null | awk '{print $1}')
  if ! grep -qxF "$sig" "$state" 2>/dev/null; then
    printf '%s\n' "$sig" >> "$state" 2>/dev/null
    printf '%s\n' "$line"
  fi
done)
[ -z "$fresh" ] && exit 0

count=$(printf '%s\n' "$fresh" | grep -c .)
samples=$(printf '%s\n' "$fresh" | head -20 | sed 's/^/  /')

reason=$(printf '直前の %s(%s) で %s 行のコメントを追加しました。WHY-only 方針(~/.codex/AGENTS.md「コメントポリシー」)に照らし、次に該当するものは作業を続ける前に削除または WHY へ書き換えてください:\n- コードを読めば分かる WHAT の二重管理\n- 実装手順の番号付き/箇条書き再記述\n- 上位レイヤ(interface/domain)への実装詳細・呼び出し元事情の漏れ\n正当な WHY コメントはそのままで構いません。\n\n検出したコメント:\n%s' "$tool" "$file" "$count" "$samples")

jq -n --arg r "$reason" '{decision:"block", reason:$r}'
exit 0
