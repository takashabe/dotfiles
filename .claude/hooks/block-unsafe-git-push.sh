#!/bin/bash
# PreToolUse hook for Bash
# AGENTS.md の到達点宣言方式でエージェントが自律的に push するようになるため、
# 取り返しのつかない push だけを決定論的に止める。通常のブランチへの push は通す。
#
# 止めるもの:
#   - 共有ブランチ（PROTECTED）への push。個人リポジトリでも例外にしない
#   - force push（--force / -f）。--force-with-lease は自分の push を上書きしない限り安全なので通す
#   - ブランチ削除（--delete / -d / :branch 形式の refspec）
#   - gh pr merge
#
# -C で別ディレクトリを指す git は、その先の現在ブランチで判定する。

set -euo pipefail

PROTECTED='^(main|master|trunk|dev|develop|development|qa|uat|stg|staging|preprod|prod|production|release|release/.*|hotfix/.*)$'

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

block() {
  cat >&2 <<MSG
Bash blocked: $1

対象コマンド: $2
共有ブランチへの直接 push、force push、ブランチ削除、PR マージはエージェントからは行わない方針です。
必要ならユーザーに理由を伝え、ユーザー自身に実行してもらってください。
MSG
  exit 2
}

# 引用符の中や echo の引数に同じ文字列が現れても誤検知しないよう、セグメント先頭に限定する。
printf '%s\n' "$COMMAND" | sed -E 's/(&&|\|\||;|\|)/\n/g' | while IFS= read -r seg; do
  if printf '%s\n' "$seg" | grep -Eq '^[[:space:]]*gh[[:space:]]+pr[[:space:]]+merge([[:space:]]|$)'; then
    block "gh pr merge はエージェントからは実行しません" "$seg"
  fi
  printf '%s\n' "$seg" | grep -Eq '^[[:space:]]*git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push([[:space:]]|$)' || continue

  # 変数展開は行わず、引数の文字列だけを見る（eval は使わない）
  read -r -a words <<<"$seg"
  dir="."
  args=()
  seen_push=0
  i=0
  while [ $i -lt ${#words[@]} ]; do
    w=${words[$i]}
    if [ $seen_push -eq 0 ]; then
      if [ "$w" = "-C" ]; then i=$((i+1)); dir=${words[$i]:-.}; fi
      [ "$w" = "push" ] && seen_push=1
    else
      args+=("$w")
    fi
    i=$((i+1))
  done

  for a in "${args[@]}"; do
    case "$a" in
      --force|-f|--force=*) block "force push は実行しません" "$seg" ;;
      --delete|-d) block "リモートブランチの削除は実行しません" "$seg" ;;
      --mirror|--prune) block "mirror / prune push は実行しません" "$seg" ;;
    esac
  done

  # 位置引数（オプション以外）から remote と refspec を取り出す
  positional=()
  skip_next=0
  for a in "${args[@]}"; do
    if [ $skip_next -eq 1 ]; then skip_next=0; continue; fi
    case "$a" in
      -o|--push-option|--receive-pack|--exec|--repo) skip_next=1 ;;
      -*) ;;
      *) positional+=("$a") ;;
    esac
  done

  dest=""
  if [ ${#positional[@]} -ge 2 ]; then
    refspec=${positional[1]}
    case "$refspec" in
      :*) block "refspec ':branch' によるリモートブランチの削除は実行しません" "$seg" ;;
      *:*) dest=${refspec#*:} ;;
      *) dest=$refspec ;;
    esac
    dest=${dest#refs/heads/}
    dest=${dest#+}
  else
    dest=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  fi
  [ -z "$dest" ] || [ "$dest" = "HEAD" ] && continue

  printf '%s\n' "$dest" | grep -Eq "$PROTECTED" || continue

  block "共有ブランチ '$dest' への直接 push は実行しません" "$seg"
done
