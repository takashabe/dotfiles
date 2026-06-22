#!/bin/bash
# PreToolUse hook for Edit|Write|MultiEdit
# git worktree 内で作業しているとき、worktree 外へのファイル書き込みをブロックする。
# AGENTS.md「Git Worktree 作業制約」をプロンプト依存から決定論的強制へ格上げするもの。
#
# 発火条件: 編集対象がリンク worktree（toplevel の .git がファイル）配下のときのみ判定する。
# メインリポジトリ・非 git ディレクトリでは何もしない（exit 0）。

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE_PATH" ] && exit 0

TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
# toplevel/.git がファイルならリンク worktree。ディレクトリ（=メインリポジトリ）なら対象外。
[ -f "$TOPLEVEL/.git" ] || exit 0

TOPLEVEL_REAL=$(cd "$TOPLEVEL" 2>/dev/null && pwd -P) || exit 0

# 対象パスを正規化（.. やシンボリックリンクを解決）。新規ファイルは親ディレクトリ基準で解決する。
dir=$(dirname "$FILE_PATH")
base=$(basename "$FILE_PATH")
if abs_dir=$(cd "$dir" 2>/dev/null && pwd -P); then
  resolved="$abs_dir/$base"
else
  case "$FILE_PATH" in
    /*) resolved="$FILE_PATH" ;;
    *) resolved="$PWD/$FILE_PATH" ;;
  esac
fi

case "$resolved" in
  "$TOPLEVEL_REAL"|"$TOPLEVEL_REAL"/*) exit 0 ;;
esac

# worktree 外でも許可する harness 管理領域。
# この制約は追跡対象のソースを worktree に隔離する目的であり、gitignore された
# 永続メモリとスクラッチ領域はその対象外。memory は ~/.claude（dotfiles への
# シンボリックリンク）配下にあり pwd -P で実体パスへ正規化されるため、$HOME 起点
# ではなくパスグロブで判定する。
case "$resolved" in
  */.claude/projects/*/memory/*) exit 0 ;;
  /private/tmp/claude-*/scratchpad/*|/tmp/claude-*/scratchpad/*) exit 0 ;;
esac

cat >&2 <<MSG
Write blocked: worktree 外への書き込みを検出しました。

  worktree root : $TOPLEVEL_REAL
  対象パス      : $resolved

git worktree 内ではすべてのファイル操作を現在の worktree 配下に限定してください。
worktree 外のファイルを編集する必要がある場合は、ユーザーに確認を取ってから行ってください。
MSG
exit 2
