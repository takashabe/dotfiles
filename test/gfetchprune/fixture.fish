# 既知状態の一時 git リポジトリを生成し work パスを stdout に echo する
function gfp_make_fixture
    set -l root (mktemp -d)
    set -l origin "$root/origin.git"
    set -l work "$root/work"
    git init --quiet --bare "$origin"
    git init --quiet -b main "$work"
    git -C "$work" config user.email t@example.com
    git -C "$work" config user.name tester
    git -C "$work" config commit.gpgsign false
    echo base >"$work/base.txt"
    git -C "$work" add -A; git -C "$work" commit --quiet -m init
    git -C "$work" remote add origin "$origin"
    git -C "$work" push --quiet -u origin main
    git -C "$work" remote set-head origin main

    # merged+pushed: main にマージ済み・upstream あり
    gfp_fx_branch "$work" feat/merged-pushed merge push
    # merged+gone: マージ後 origin ブランチ削除→gone
    gfp_fx_branch "$work" feat/merged-gone merge push gone
    # gone-unmerged: 未マージで push→origin 削除→gone(固有コミットあり)
    gfp_fx_branch "$work" feat/gone-unmerged nomerge push gone
    # unmerged+pushed: 未マージ・upstream あり
    gfp_fx_branch "$work" feat/unmerged-pushed nomerge push
    # local-merged: マージ済み・upstream なし
    gfp_fx_branch "$work" feat/local-merged merge nopush
    # merged-dirty: マージ済み+push(worktree を tracked dirty にする)
    gfp_fx_branch "$work" feat/merged-dirty merge push
    # merged-untracked: マージ済み+push(worktree に untracked を置く)
    gfp_fx_branch "$work" feat/merged-untracked merge push
    # stg: マージ済み+push(ハードコード保護)
    gfp_fx_branch "$work" stg merge push
    # review 用: マージ済み+push(パス保護の検証に使う)
    gfp_fx_branch "$work" feat/review-slot merge push
    # current-wip: 未マージ+push(カレント HEAD 専用。skip-current 検証用)
    gfp_fx_branch "$work" feat/current-wip nomerge push

    git -C "$work" fetch origin --prune --quiet

    # 現在の HEAD を default 以外・未マージの専用ブランチにする
    # (feat/unmerged-pushed は worktree なしのまま pass2 で keep-unmerged に分類させる)
    git -C "$work" checkout --quiet feat/current-wip

    # worktree 群
    git -C "$work" worktree add --quiet "$root/wt/merged-pushed" feat/merged-pushed
    git -C "$work" worktree add --quiet "$root/wt/merged-gone" feat/merged-gone
    git -C "$work" worktree add --quiet "$root/wt/gone-unmerged" feat/gone-unmerged
    git -C "$work" worktree add --quiet "$root/wt/merged-dirty" feat/merged-dirty
    echo changed >"$root/wt/merged-dirty/base.txt"
    git -C "$work" worktree add --quiet "$root/wt/merged-untracked" feat/merged-untracked
    echo junk >"$root/wt/merged-untracked/untracked.txt"
    git -C "$work" worktree add --quiet "$work/.git/.wkit-worktrees/review" feat/review-slot
    git -C "$work" worktree add --quiet --detach "$root/wt/detached"

    echo "$work"
end

# helper: ブランチを作り merge/nomerge・push/nopush・gone を制御する
function gfp_fx_branch --argument-names work name mode push gone
    git -C "$work" checkout --quiet -b "$name" main
    set -l flat_name (string replace -a '/' '-' "$name")
    echo "$name" >"$work/$flat_name-file.txt"
    git -C "$work" add -A; git -C "$work" commit --quiet -m "$name work"
    if test "$push" = push
        git -C "$work" push --quiet -u origin "$name"
    end
    if test "$mode" = merge
        git -C "$work" checkout --quiet main
        git -C "$work" merge --quiet --no-ff -m "merge $name" "$name"
        git -C "$work" push --quiet origin main
        git -C "$work" checkout --quiet "$name"
    end
    if test "$gone" = gone
        git -C "$work" push --quiet origin --delete "$name"
    end
    git -C "$work" checkout --quiet main
end
