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

# 引用符の中や echo の引数に同じ文字列が現れても誤検知しないよう、コマンド語の位置だけを見る。
printf '%s\n' "$COMMAND" | sed -E 's/(&&|\|\||;|\||&|\(|\)|`|\$\()/\n/g' | while IFS= read -r seg; do
  # 変数展開は行わず、引数の文字列だけを見る（eval は使わない）
  read -r -a words <<<"$seg"
  [ ${#words[@]} -eq 0 ] && continue

  i=0
  while [ $i -lt ${#words[@]} ]; do
    case "${words[$i]}" in
      env|sudo|command|nohup|time|exec|nice|xargs) i=$((i+1)) ;;
      [A-Za-z_]*=*) i=$((i+1)) ;;
      *) break ;;
    esac
  done
  [ $i -ge ${#words[@]} ] && continue
  cmd=${words[$i]##*/}

  if [ "$cmd" = "gh" ] && [ "${words[$((i+1))]:-}" = "pr" ] && [ "${words[$((i+2))]:-}" = "merge" ]; then
    block "gh pr merge はエージェントからは実行しません" "$seg"
  fi
  [ "$cmd" = "git" ] || continue

  dir="."
  i=$((i+1))
  sub=""
  while [ $i -lt ${#words[@]} ]; do
    w=${words[$i]}
    case "$w" in
      -C) i=$((i+1)); dir=${words[$i]:-.} ;;
      -c|--git-dir|--work-tree|--namespace|--exec-path) i=$((i+1)) ;;
      -*) ;;
      *) sub=$w; break ;;
    esac
    i=$((i+1))
  done
  [ "$sub" = "push" ] || continue
  args=("${words[@]:$((i+1))}")

  positional=()
  skip_next=0
  tags_only=0
  for a in "${args[@]}"; do
    if [ $skip_next -eq 1 ]; then skip_next=0; continue; fi
    case "$a" in
      --tags) tags_only=1 ;;
      --force|--force=*) block "force push は実行しません" "$seg" ;;
      --delete) block "リモートブランチの削除は実行しません" "$seg" ;;
      --mirror|--prune|--all|--branches) block "mirror / prune / all / branches push は実行しません" "$seg" ;;
      --force-with-lease|--force-with-lease=*|--force-if-includes) ;;
      --*) case "$a" in --push-option|--receive-pack|--exec|--repo) skip_next=1 ;; esac ;;
      -o) skip_next=1 ;;
      -*)
        # -fu のような束でも force / delete を見逃さないため、文字単位で見る
        case "${a#-}" in
          *f*) block "force push は実行しません" "$seg" ;;
          *d*) block "リモートブランチの削除は実行しません" "$seg" ;;
        esac ;;
      *) positional+=("$a") ;;
    esac
  done

  dests=()
  if [ ${#positional[@]} -ge 2 ]; then
    # 複数 refspec のうち 1 つでも共有ブランチを指せば止める
    for refspec in "${positional[@]:1}"; do
      case "$refspec" in
        +*) block "refspec '+' による force push は実行しません" "$seg" ;;
        :*) block "refspec ':branch' によるリモートブランチの削除は実行しません" "$seg" ;;
        *:*) d=${refspec#*:} ;;
        HEAD) d=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true) ;;
        *) d=$refspec ;;
      esac
      dests+=("${d#refs/heads/}")
    done
  elif [ $tags_only -eq 0 ]; then
    dests+=("$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)")
  fi

  for dest in "${dests[@]}"; do
    [ -z "$dest" ] || [ "$dest" = "HEAD" ] && continue
    printf '%s\n' "$dest" | grep -Eq "$PROTECTED" || continue
    block "共有ブランチ '$dest' への直接 push は実行しません" "$seg"
  done
done
