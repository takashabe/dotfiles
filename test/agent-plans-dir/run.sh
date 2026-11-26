#!/usr/bin/env bash
set -uo pipefail

cmd=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../bin" && pwd -P)/agent-plans-dir
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
notes="$work/notes"

failures=0

expect_eq() {
  if [ "$2" = "$3" ]; then
    printf 'ok   %s\n' "$1"
  else
    printf 'FAIL %s\n     want: %s\n     got:  %s\n' "$1" "$3" "$2"
    failures=$((failures + 1))
  fi
}

expect_fail() {
  local name=$1 want=$2 out status
  shift 2
  out=$("$@" 2>&1)
  status=$?
  if [ "$status" -ne 0 ] && [[ $out == *"$want"* ]]; then
    printf 'ok   %s\n' "$name"
  else
    printf 'FAIL %s\n     status=%s out=%s\n' "$name" "$status" "$out"
    failures=$((failures + 1))
  fi
}

new_repo() {
  git init -q -b main "$1"
  git -C "$1" -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m init
  if [ -n "${2:-}" ]; then git -C "$1" remote add origin "$2"; fi
}

run() {
  local dir=$1
  shift
  (cd "$dir" && AGENT_NOTES_DIR=$notes "$cmd" "$@")
}

new_repo "$work/repo" "git@github.com:Owner/repo.git"
git -C "$work/repo" worktree add -q "$work/wt/feat/task-a" -b feat/task-a
plans="$notes/github.com/Owner/repo/plans"

expect_eq "メインの worktree" "$(run "$work/repo")" "$plans/_main"
expect_eq "linked worktree は worktree の名前で分かれる" "$(run "$work/wt/feat/task-a")" "$plans/task-a"
expect_eq "--main は linked worktree からもメインを返す" "$(run "$work/wt/feat/task-a" --main)" "$plans/_main"
expect_eq "--all はリポジトリ全体を返す" "$(run "$work/wt/feat/task-a" --all)" "$plans"
expect_eq "サブディレクトリから呼んでも同じ" \
  "$(mkdir -p "$work/wt/feat/task-a/sub" && run "$work/wt/feat/task-a/sub")" "$plans/task-a"

git -C "$work/wt/feat/task-a" switch -q -c feat/task-b
expect_eq "ブランチを替えても同じ場所" "$(run "$work/wt/feat/task-a")" "$plans/task-a"

git -C "$work/wt/feat/task-a" switch -q --detach
expect_eq "detached HEAD でも同じ場所" "$(run "$work/wt/feat/task-a")" "$plans/task-a"

git -C "$work/repo" worktree add -q "$work/wt/fix/task-a" -b fix/task-a
expect_eq "末尾が同じ別の worktree は別の場所" \
  "$([ "$(run "$work/wt/fix/task-a")" != "$plans/task-a" ] && echo differs)" "differs"

git -C "$work/repo" worktree add -q "$work/wt/_main" -b underscore
expect_eq "_main という名前の worktree はメインと重ならない" \
  "$([ "$(run "$work/wt/_main")" != "$plans/_main" ] && echo differs)" "differs"

new_repo "$work/no-origin"
expect_eq "origin がない" "$(run "$work/no-origin")" "$notes/local/no-origin/plans/_main"

new_repo "$work/https" "https://user@example.com:8443/group/sub/repo.git/"
expect_eq "https 形式の origin" "$(run "$work/https")" "$notes/example.com/group/sub/repo/plans/_main"

expect_eq "置き場が未設定なら XDG_DATA_HOME の下" \
  "$(cd "$work/repo" && env -u AGENT_NOTES_DIR XDG_DATA_HOME="$work/xdg" "$cmd")" \
  "$work/xdg/agent-notes/github.com/Owner/repo/plans/_main"
expect_eq "~/ で始まる置き場" \
  "$(cd "$work/repo" && HOME="$work/home" AGENT_NOTES_DIR='~/n' "$cmd")" \
  "$work/home/n/github.com/Owner/repo/plans/_main"

expect_eq "出力したディレクトリは作られている" "$([ -d "$plans/task-a" ] && echo exists)" "exists"

new_repo "$work/dots" "git@github.com:Owner/../escape.git"
expect_fail "origin に .. がある" "使えない名前" run "$work/dots"
expect_fail "相対パスの置き場" "絶対パス" env AGENT_NOTES_DIR=rel bash -c "cd '$work/repo' && '$cmd'"
expect_fail "未知の引数" "usage" run "$work/repo" --branch
expect_fail "引数が多い" "usage" run "$work/repo" --main --all
expect_fail "git の外" "git リポジトリ" env GIT_CEILING_DIRECTORIES="$work" AGENT_NOTES_DIR="$notes" bash -c "cd '$work' && '$cmd'"

if [ "$failures" -gt 0 ]; then
  printf '\n%d 件失敗\n' "$failures"
  exit 1
fi
printf '\nすべて成功\n'
