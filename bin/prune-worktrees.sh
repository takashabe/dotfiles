#!/usr/bin/env bash
#
# 残したいブランチ(KEEP_BRANCHES)に紐づく worktree とメイン worktree のみを残し、
# それ以外をすべて削除する。マージ・push 状態は問わず一掃する点が gfetchprune と異なる。
#
# 残すブランチは KEEP_BRANCHES に半角スペース区切りの短縮名で渡す。未指定時は
# 主要な保護ブランチ(main/dev 等)のみを残す。
#   プレビュー : KEEP_BRANCHES='feat/foo feat/bar' ./prune-worktrees.sh
#   実削除     : DRY_RUN=0 KEEP_BRANCHES='feat/foo feat/bar' ./prune-worktrees.sh
#
# 既定は dry-run（削除対象を表示するだけ）。実削除は DRY_RUN=0 を指定する。
#
# dry-run では削除対象を「作成日が古い順」にソートして表示する。
# created      = worktree ディレクトリの作成時刻 (APFS birthtime / macOS 前提)
# last-commit  = その worktree の HEAD コミット日 (コードの古さの目安)
#
# 個々の worktree 削除に失敗しても中断せず継続し、末尾に失敗一覧を出す。
#
set -uo pipefail

# 残すブランチ(短縮名)。KEEP_BRANCHES 未指定なら主要な保護ブランチを既定とする。
if [[ -n "${KEEP_BRANCHES:-}" ]]; then
  read -ra KEEP <<< "$KEEP_BRANCHES"
else
  KEEP=(main master stg qa dev develop staging production prod)
fi

DRY_RUN="${DRY_RUN:-1}"

log() { printf '%s %s\n' "$(date '+%H:%M:%S')" "$*"; }

# worktree ディレクトリの作成時刻 (epoch)。取れなければ 0
birth_epoch() { stat -f '%B' "$1" 2>/dev/null || echo 0; }

fmt_date() {  # epoch -> 表示用。0 や空なら "----------"
  [[ -z "$1" || "$1" == "0" ]] && { printf '%s' "----------"; return; }
  date -r "$1" '+%Y-%m-%d'
}

last_commit_date() {  # sha -> コミット日。取れなければ "----------"
  git show -s --format='%cd' --date=format:'%Y-%m-%d' "$1" 2>/dev/null || printf '%s' "----------"
}

# 先頭 worktree が常にメイン worktree。
# awk を最初の一致で exit させると上流の git に SIGPIPE が伝わり pipefail で
# 落ちる(終了コード 141)ため、early-exit せずフラグで先頭のみ採用する。
MAIN_WT="$(git worktree list --porcelain | awk '/^worktree / && !seen {print $2; seen=1}')"
if [[ -z "$MAIN_WT" ]]; then
  log "ERROR: メイン worktree を特定できませんでした (ここは git リポジトリ内ですか?)"
  exit 1
fi
log "main worktree (保持): $MAIN_WT"
log "keep branches: ${KEEP[*]}"

is_keep() {
  local branch="$1"
  [[ -z "$branch" ]] && return 1
  for k in "${KEEP[@]}"; do
    [[ "$branch" == "$k" ]] && return 0
  done
  return 1
}

removed=0
kept=0
failed=0
failed_list=()
candidates=()  # dry-run のソート用: "epoch\tcreated\tlastcommit\tbranch\tpath"

while IFS=$'\037' read -r path branch head; do
  [[ -z "$path" ]] && continue

  # porcelain の branch は refs/heads/ 付き。KEEP は短縮名で受けるため揃える。
  branch_short="${branch#refs/heads/}"

  epoch="$(birth_epoch "$path")"
  created="$(fmt_date "$epoch")"
  committed="$(last_commit_date "$head")"
  label="${branch_short:-detached}"

  if [[ "$path" == "$MAIN_WT" ]] || is_keep "$branch_short"; then
    log "keep   : created=$created last-commit=$committed  $path  [$label]"
    kept=$((kept + 1))
    continue
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    candidates+=("$epoch"$'\037'"$created"$'\037'"$committed"$'\037'"$label"$'\037'"$path")
    removed=$((removed + 1))
    continue
  fi

  # 通常の --force で消えないロック済み worktree は --force を二重指定で再試行する
  if err="$(git worktree remove --force "$path" 2>&1)" \
     || err="$(git worktree remove --force --force "$path" 2>&1)"; then
    log "removed: created=$created last-commit=$committed  $path  [$label]"
    removed=$((removed + 1))
  else
    log "FAILED : $path  [$label]"
    [[ -n "$err" ]] && log "         $err"
    failed=$((failed + 1))
    failed_list+=("$path")
  fi
done < <(git worktree list --porcelain | awk -v RS='' '
{
  path=""; branch=""; head=""
  for (i = 1; i <= NF; i++) {
    if ($i == "worktree") path = $(i + 1)
    if ($i == "branch")   branch = $(i + 1)
    if ($i == "HEAD")     head = $(i + 1)
  }
  printf "%s\037%s\037%s\n", path, branch, head
}')

echo "----"
if [[ "$DRY_RUN" == "1" ]]; then
  echo "削除対象 (作成が古い順):"
  printf '  %-12s %-12s %s\n' "created" "last-commit" "branch / path"
  printf '%s\n' "${candidates[@]}" | sort -t$'\037' -k1,1n | while IFS=$'\037' read -r _epoch created committed label path; do
    printf '  %-12s %-12s %s\n' "$created" "$committed" "$label"
    printf '  %-12s %-12s   %s\n' "" "" "$path"
  done
  echo "----"
  log "[dry-run] 削除対象: ${removed} 件 / 保持: ${kept} 件  (実削除は DRY_RUN=0 を付与)"
else
  git worktree prune
  log "削除: ${removed} 件 / 失敗: ${failed} 件 / 保持: ${kept} 件  (git worktree prune 実行済み)"
  if (( failed > 0 )); then
    log "削除失敗 ${failed} 件 (手動対応が必要):"
    for p in "${failed_list[@]}"; do
      log "  - $p"
    done
  fi
fi
