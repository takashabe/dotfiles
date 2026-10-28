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

# git が受け付ける長オプションの省略形（--forc など）も同じ意味として扱う
long_opt_is() {
  local opt=${1#--} full=$2
  opt=${opt%%=*}
  [ -n "$opt" ] && [ "${full#"$opt"}" != "$full" ]
}

current_branch() {
  git -C "$1" rev-parse --abbrev-ref HEAD 2>/dev/null || true
}

# 引用符の中や echo の引数に同じ文字列が現れても誤検知しないよう、コマンド語の位置だけを見る。
# "git" push や git\ push のような引用・エスケープで語を崩す形は、先に剥がしてから比較する。
printf '%s\n' "$COMMAND" | sed -E 's/(&&|\|\||;|\||&|\(|\)|\{|\}|`|\$\(|\n)/\n/g; s/["'"'"'\\]//g' | while IFS= read -r seg; do
  # 変数展開は行わず、引数の文字列だけを見る（eval は使わない）
  read -r -a words <<<"$seg"
  [ ${#words[@]} -eq 0 ] && continue

  i=0
  git_env_override=0
  while [ $i -lt ${#words[@]} ]; do
    w=${words[$i]}
    case "$w" in
      env|sudo|command|nohup|time|exec|nice|builtin|timeout|doas|!)
        i=$((i+1))
        while [ $i -lt ${#words[@]} ]; do
          case "${words[$i]}" in
            -u|-g|-n|-C|-S|-s|-k|--user|--group|--adjust|--chdir|--signal|--kill-after) i=$((i+2)) ;;
            -*) i=$((i+1)) ;;
            *) break ;;
          esac
        done
        if [ "$w" = "timeout" ]; then
          case "${words[$i]:-}" in [0-9]*) i=$((i+1)) ;; esac
        fi ;;
      GIT_CONFIG*=*|GIT_DIR=*|GIT_WORK_TREE=*|GIT_ALTERNATE*=*) git_env_override=1; i=$((i+1)) ;;
      [A-Za-z_]*=*) i=$((i+1)) ;;
      *) break ;;
    esac
  done
  [ $i -ge ${#words[@]} ] && continue
  cmd=${words[$i]##*/}

  # GIT_CONFIG_* や GIT_DIR で設定や対象リポジトリを差し替えられると、以降の判定が成り立たない
  if [ "$cmd" = "git" ] && [ $git_env_override -eq 1 ]; then
    block "GIT_CONFIG_* / GIT_DIR / GIT_WORK_TREE を付けた git は、設定や対象リポジトリを判定できないため実行しません" "$seg"
  fi

  # 別のインタプリタに文字列を渡す形は中身を解析できないので、push / merge を含むなら fail-closed にする
  case "$cmd" in
    eval|bash|sh|zsh|fish|dash|xargs|find|script|expect|perl|python|python3|ruby|node)
      # 渡される文字列はセグメント分割で散るので、コマンド全体を見る
      if printf '%s\n' "$COMMAND" | sed -E 's/["'"'"'\\]//g' | grep -Eq '(^|[^[:alnum:]_-])(push|merge)([^[:alnum:]_-]|$)'; then
        block "$cmd 経由で push / merge を含むコマンドは解析できないため実行しません" "$seg"
      fi
      continue ;;
  esac

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
      -c|--config-env|-c*|--config-env=*)
        case "$w" in
          -c|--config-env) i=$((i+1)); key=${words[$i]:-} ;;
          --config-env=*) key=${w#--config-env=} ;;
          *) key=${w#-c} ;;
        esac
        # git の設定キーは大文字小文字を区別しないので、小文字に揃えてから比較する
        key=${key,,}
        # alias や push 先の設定を一時的に上書きすると、この hook の判定が成り立たなくなる
        case "$key" in
          alias.*|push.*|remote.*|url.*|branch.*|include.*|includeif.*|core.hookspath*|credential.*|=*|"")
            block "git -c による alias / push 先 / include / 認証設定の上書きは実行しません" "$seg" ;;
        esac ;;
      --git-dir|--work-tree|--namespace|--exec-path|--git-dir=*|--work-tree=*|--namespace=*|--exec-path=*)
        block "git --git-dir / --work-tree / --exec-path 付きの実行は、対象リポジトリを判定できないため行いません" "$seg" ;;
      -*) ;;
      *) sub=$w; break ;;
    esac
    i=$((i+1))
  done
  [ -n "$sub" ] || continue

  # 組み込みでないサブコマンドは alias の可能性がある。展開先に push が含まれるなら fail-closed にする
  if [ "$sub" != "push" ]; then
    # alias が別の alias を指すこともあるので、展開を辿り切るまで見る（循環対策で上限を置く）
    name=$sub
    depth=0
    while [ $depth -lt 8 ]; do
      expansion=$(git -C "$dir" config --get "alias.$name" 2>/dev/null || true)
      [ -z "$expansion" ] && break
      if printf '%s\n' "$expansion" | grep -Eq '(^|[^[:alnum:]_-])push([^[:alnum:]_-]|$)|^!'; then
        block "alias '$sub' の展開先に push またはシェル実行が含まれるため実行しません" "$seg"
      fi
      name=${expansion%% *}
      depth=$((depth+1))
    done
    continue
  fi
  args=("${words[@]:$((i+1))}")

  positional=()
  skip_next=0
  tags_only=0
  for a in "${args[@]}"; do
    if [ $skip_next -eq 1 ]; then skip_next=0; continue; fi
    case "$a" in
      --) ;;
      --force-with-lease|--force-with-lease=*|--force-if-includes|--no-force-with-lease|--no-force-if-includes) ;;
      --tags) tags_only=1 ;;
      --set-upstream|--verbose|--quiet|--dry-run|--porcelain|--no-verify|--verify|--follow-tags|--atomic|--no-atomic|--thin|--no-thin|--progress|--no-progress|--signed|--signed=*|--no-signed|--recurse-submodules=*|--no-recurse-submodules|--ipv4|--ipv6) ;;
      --push-option=*|--receive-pack=*|--exec=*|--repo=*) ;;
      --push-option|--receive-pack|--exec|--repo) skip_next=1 ;;
      --*)
        for danger in force delete mirror prune all branches; do
          if long_opt_is "$a" "$danger"; then
            block "'$a' は --$danger の省略形として扱い、実行しません" "$seg"
          fi
        done
        # 未知の長オプションは意味を判定できないので fail-closed にする
        block "未知の push オプション '$a' は実行しません" "$seg" ;;
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
        *\**) block "ワイルドカードを含む refspec '$refspec' は push 先を判定できないため実行しません" "$seg" ;;
        +*) block "refspec '+' による force push は実行しません" "$seg" ;;
        :*) block "refspec ':branch' によるリモートブランチの削除は実行しません" "$seg" ;;
        *:*) d=${refspec#*:} ;;
        HEAD|@) d=$(current_branch "$dir") ;;
        *) d=$refspec ;;
      esac
      case "$d" in HEAD|@) d=$(current_branch "$dir") ;; esac
      dests+=("${d#refs/heads/}")
    done
  elif [ $tags_only -eq 0 ]; then
    dests+=("$(current_branch "$dir")")
  fi

  for dest in "${dests[@]}"; do
    [ -z "$dest" ] || [ "$dest" = "HEAD" ] && continue
    printf '%s\n' "$dest" | grep -Eq "$PROTECTED" || continue
    block "共有ブランチ '$dest' への直接 push は実行しません" "$seg"
  done
done
