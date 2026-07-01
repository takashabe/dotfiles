#!/usr/bin/env bash
# WHY: 「コメントは WHY のみ」方針が生成時の注意欠落で守られないための補償コントロール。
# 別プロセスの LLM ジャッジを置かないのは、原因が能力不足でなく注意欠落であり、
# 本体モデルに再点検させるだけで低コストに矯正できるため。
set -uo pipefail

input=$(cat)

# 無限ループ防止（自身の差し戻しによる再 Stop で再発火させないため）
if [ "$(jq -r '.stop_hook_active // false' <<<"$input" 2>/dev/null)" = "true" ]; then
  exit 0
fi

session_id=$(jq -r '.session_id // "unknown"' <<<"$input" 2>/dev/null)
cwd=$(jq -r '.cwd // env.CLAUDE_PROJECT_DIR // "."' <<<"$input" 2>/dev/null)

cd "$cwd" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# git diff HEAD は untracked を見ず新規作成ファイルを取りこぼすため、その全行を追加行として補う
report=$( {
  git diff HEAD --unified=0 --no-color 2>/dev/null
  git ls-files --others --exclude-standard -z 2>/dev/null | while IFS= read -r -d '' f; do
    printf '+++ b/%s\n' "$f"
    sed 's/^/+/' "$f" 2>/dev/null
  done
} | awk '
  function ext(f,   n,a) { n=split(f,a,"."); return (n>1)?tolower(a[n]):"" }
  /^\+\+\+ b\// { file=substr($0,7); e=ext(file); next }
  /^\+\+\+ / { file=""; e=""; next }
  /^\+/ && $0 !~ /^\+\+\+/ {
    t=substr($0,2); sub(/^[[:space:]]+/,"",t)
    is=0
    if (e=="go"||e=="ts"||e=="tsx"||e=="js"||e=="jsx"||e=="mjs"||e=="cjs"||e=="rs"||e=="java"||e=="kt"||e=="kts"||e=="c"||e=="cc"||e=="cpp"||e=="h"||e=="hpp"||e=="swift"||e=="scala") {
      if (t ~ /^\/\// || t ~ /^\/\*/ || t ~ /^\*/) is=1
    } else if (e=="sql"||e=="lua") {
      if (t ~ /^--/) is=1
    } else if (e=="py"||e=="rb"||e=="sh"||e=="bash"||e=="zsh") {
      if (t ~ /^#/ && t !~ /^#!/) is=1
    }
    if (is) { c++; if (c<=20) print "  " file ": " t }
  }
  END { if (c>0) print "___COUNT___" c }
') || exit 0

count=$(printf '%s\n' "$report" | sed -n 's/^___COUNT___//p')
[ -z "$count" ] && exit 0

samples=$(printf '%s\n' "$report" | grep -v '^___COUNT___' || true)

# 同一の検出結果に対する再ナッジを抑止（監査済みで残したコメントを毎ターン蒸し返さない）
sig=$(printf '%s\n%s' "$count" "$samples" | shasum 2>/dev/null | awk '{print $1}')
state="${TMPDIR:-/tmp}/claude-self-audit-${session_id}.sig"
if [ -f "$state" ] && [ "$(cat "$state" 2>/dev/null)" = "$sig" ]; then
  exit 0
fi
printf '%s' "$sig" > "$state" 2>/dev/null || true

reason=$(printf 'このターンで %s 行のコメントを追加/変更しました。各コメントを WHY-only 方針（~/.codex/AGENTS.md「コメントポリシー」）に照らして自己監査し、次に該当するものは削除または WHY へ書き換えてください:\n- コードを読めば分かる WHAT の二重管理\n- 実装手順の番号付き/箇条書き再記述\n- 上位レイヤ(interface/domain)への実装詳細・呼び出し元事情の漏れ\n監査した結果すべて正当な WHY コメントなら、その旨を一言添えて完了して構いません。\n\n検出したコメント(最大20件):\n%s' "$count" "$samples")

jq -n --arg r "$reason" '{decision:"block", reason:$r}'
exit 0
