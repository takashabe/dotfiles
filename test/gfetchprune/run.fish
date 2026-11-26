#!/usr/bin/env fish
source (status dirname)/../../.config/fish/gfetchprune.fish
source (status dirname)/fixture.fish

# local.fish 相当: パス保護は repo 既定を持たず PROTECT_WORKTREE_PATHS で設定する。
# review 枠保護を検証するアサーションはこの設定に依存する。
set -g PROTECT_WORKTREE_PATHS '*/keep-worktrees/slot'

set -g GFP_FAILS 0
function gfp_assert --argument-names desc
    # 条件は2形態で渡される: 単一文字列(not やリダイレクトを含む→eval 必須)と
    # 複数語(各要素を直接コマンド実行=空白を含む値も保てて安全)。両者を分けて扱う。
    set -l ok 0
    if test (count $argv) -eq 2
        eval $argv[2]; and set ok 1
    else
        if $argv[2..-1]
            set ok 1
        end
    end
    if test $ok -eq 1
        echo "  ok: $desc"
    else
        echo "FAIL: $desc"
        set -g GFP_FAILS (math $GFP_FAILS + 1)
    end
end

set -g GFP_WORK (gfp_make_fixture)
cd "$GFP_WORK"

# 引数解析: 既定は dry-run(実削除しない=worktree 数が減らない)
set -l before (git worktree list --porcelain | grep -c '^worktree ')
gfetchprune >/dev/null
set -l after (git worktree list --porcelain | grep -c '^worktree ')
gfp_assert "default は dry-run(削除しない)" test $before -eq $after

# -x -n は dry-run 優先(削除しない)
gfetchprune -x -n >/dev/null
set -l after2 (git worktree list --porcelain | grep -c '^worktree ')
gfp_assert "-x -n は dry-run 優先" test $before -eq $after2

# 未知引数は exit 1
gfp_assert "未知引数で Usage 終了" "not gfetchprune --bogus >/dev/null 2>&1"

gfp_assert "default branch は main" test (__gfp_default_branch) = main
gfp_assert "merge_target は origin/main" test (__gfp_merge_target main) = refs/remotes/origin/main
gfp_assert "merge_target 不在は exit1" "not __gfp_merge_target nonexistent >/dev/null 2>&1"

# origin を壊して fetch 失敗時に exit1 することを確認(別 fixture)
set -l broken (gfp_make_fixture)
git -C "$broken" remote set-url origin /nonexistent/path.git
pushd "$broken" >/dev/null
gfp_assert "fetch 失敗で exit1" "not gfetchprune >/dev/null 2>&1"
popd >/dev/null
rm -rf (dirname "$broken")

# gone は track(長形式)で検出できる(trackshort では不可)
set -l gline (__gfp_branch_meta | string match -e 'feat/merged-gone')
gfp_assert "merged-gone の track が gone" "string match -q '*gone*' -- '$gline'"
set -l uline (__gfp_branch_meta | string match -e 'feat/unmerged-pushed')
gfp_assert "unmerged-pushed は gone でない" "not string match -q '*gone*' -- '$uline'"

gfp_assert "stg は保護" "__gfp_is_protected_branch stg"
gfp_assert "release/x は保護" "__gfp_is_protected_branch release/2026-q2"
gfp_assert "feat/foo は非保護" "not __gfp_is_protected_branch feat/foo"
# PROTECT_BRANCHES がリストでも完全一致で効く・空でも壊れない
set -g PROTECT_BRANCHES keepme other
gfp_assert "リスト PROTECT_BRANCHES が効く" "__gfp_is_protected_branch keepme"
set -e PROTECT_BRANCHES
gfp_assert "空 PROTECT_BRANCHES で誤保護しない" "not __gfp_is_protected_branch ''"

gfp_assert "保護パスは保護(PROTECT_WORKTREE_PATHS 一致)" "__gfp_is_protected_path $GFP_WORK/.git/keep-worktrees/slot"
gfp_assert "通常 worktree は非保護" "not __gfp_is_protected_path /tmp/wt/merged-pushed"

set -l root (dirname "$GFP_WORK")
gfp_assert "clean を判定" test (__gfp_worktree_dirty_kind "$root/wt/merged-pushed") = clean
gfp_assert "tracked 変更を判定" test (__gfp_worktree_dirty_kind "$root/wt/merged-dirty") = tracked
gfp_assert "untracked を判定" test (__gfp_worktree_dirty_kind "$root/wt/merged-untracked") = untracked

set -l rows (__gfp_classify main refs/remotes/origin/main)
# fish では "$list" が空白結合され壊れるので、br を先頭・rows を残余引数で受ける
function gfp_cat_of --argument-names br
    for r in $argv[2..-1]
        set -l p (string split \t -- $r)
        test "$p[2]" = "$br"; and echo $p[1]; and return 0
    end
end
gfp_assert "merged-pushed は delete-wt" test (gfp_cat_of feat/merged-pushed $rows) = delete-wt
gfp_assert "merged-gone は delete-wt" test (gfp_cat_of feat/merged-gone $rows) = delete-wt
gfp_assert "gone-unmerged は confirm-gone" test (gfp_cat_of feat/gone-unmerged $rows) = confirm-gone
gfp_assert "unmerged-pushed は keep-unmerged" test (gfp_cat_of feat/unmerged-pushed $rows) = keep-unmerged
gfp_assert "local-merged は protect-nopush" test (gfp_cat_of feat/local-merged $rows) = protect-nopush
gfp_assert "stg は protect-branch" test (gfp_cat_of stg $rows) = protect-branch
gfp_assert "merged-dirty は skip-dirty" test (gfp_cat_of feat/merged-dirty $rows) = skip-dirty
gfp_assert "merged-untracked は confirm-untracked" test (gfp_cat_of feat/merged-untracked $rows) = confirm-untracked
gfp_assert "review-slot は protect-path" test (gfp_cat_of feat/review-slot $rows) = protect-path
gfp_assert "最終更新が古い push 無 merged の worktree は delete-wt" test (gfp_cat_of feat/stale-wt $rows) = delete-wt
gfp_assert "最終更新が古い push 無 merged の branch は delete-branch" test (gfp_cat_of feat/stale-nowt $rows) = delete-branch
gfp_assert "古いブランチでも今日 worktree に出したものは protect-nopush" test (gfp_cat_of feat/revived-wt $rows) = protect-nopush
gfp_assert "reflog の無い worktree は protect-nopush" test (gfp_cat_of feat/nolog-wt $rows) = protect-nopush
gfp_assert "reflog の無い worktree は reflog なしと表示" string match -q '*feat/nolog-wt*reflog なし*' -- $rows
gfp_assert "reflog の無い worktree 無し branch は delete-branch" test (gfp_cat_of feat/nolog-nowt $rows) = delete-branch

set -g GFP_STALE_DAYS 60
set -l rows_long (__gfp_classify main refs/remotes/origin/main)
gfp_assert "GFP_STALE_DAYS を超えない間は protect-nopush" test (gfp_cat_of feat/stale-wt $rows_long) = protect-nopush
set -g GFP_STALE_DAYS abc
gfp_assert "数値でない GFP_STALE_DAYS は既定値" test (__gfp_stale_days) = 7
set -e GFP_STALE_DAYS

set -l saved_url (git remote get-url origin)
git remote set-url origin git@github.com:acme/widgets.git
gfp_assert "ssh 形式の github remote を解釈" test (string join / (__gfp_github_repo)) = acme/widgets
git remote set-url origin https://github.com/acme/widgets
gfp_assert "https 形式(.git なし)の github remote を解釈" test (string join / (__gfp_github_repo)) = acme/widgets
git remote set-url origin $saved_url
gfp_assert "github 以外の remote は対象外" test (count (__gfp_github_repo)) -eq 0
gfp_assert "github 以外の remote では PR 取得が対象外(2)" "__gfp_fetch_prs feat/x; test \$status -eq 2"

set -l out (gfetchprune 2>&1 | string collect)
gfp_assert "出力に削除予定見出し" "string match -q '*削除予定*' -- '$out'"
gfp_assert "出力に gone-only 要確認" "string match -q '*gone-unmerged*' -- '$out'"
gfp_assert "出力に保護(push無)" "string match -q '*local-merged*' -- '$out'"
gfp_assert "コピーファイル注意を表示" "string match -q '*.env.local*' -- '$out'"

set -l ex (gfp_make_fixture)
pushd "$ex" >/dev/null
git fetch origin --prune --quiet
gfetchprune --execute >/dev/null
set -l left (git worktree list --porcelain | grep '^branch ' | string replace 'branch refs/heads/' '')
gfp_assert "merged-pushed worktree は削除された" "not contains feat/merged-pushed $left"
gfp_assert "merged-gone worktree は削除された" "not contains feat/merged-gone $left"
gfp_assert "stg は保護され残る" "contains stg $left"
gfp_assert "gone-unmerged は既定で残る" "contains feat/gone-unmerged $left"
gfp_assert "merged-dirty は残る" "contains feat/merged-dirty $left"
gfp_assert "review-slot は保護され残る" "contains feat/review-slot $left"
set -l brs (git branch --format='%(refname:short)')
gfp_assert "merged-pushed branch も削除" "not contains feat/merged-pushed $brs"
gfp_assert "local-merged branch は残る(push無保護)" "contains feat/local-merged $brs"
gfp_assert "stale-wt の worktree と branch は削除" "not contains feat/stale-wt $left; and not contains feat/stale-wt $brs"
gfp_assert "stale-nowt branch は削除" "not contains feat/stale-nowt $brs"
gfp_assert "nolog-wt は残る" "contains feat/nolog-wt $left"
popd >/dev/null
rm -rf (dirname "$ex")

set -l fx1 (gfp_make_fixture)
pushd "$fx1" >/dev/null
git fetch origin --prune --quiet
gfetchprune --include-gone-unmerged --execute >/dev/null
set -l left1 (git worktree list --porcelain | grep '^branch ' | string replace 'branch refs/heads/' '')
gfp_assert "include-gone-unmerged で gone-unmerged worktree 削除" "not contains feat/gone-unmerged $left1"
set -l brs1 (git branch --format='%(refname:short)')
gfp_assert "include-gone-unmerged で gone-unmerged branch も -D" "not contains feat/gone-unmerged $brs1"
popd >/dev/null
rm -rf (dirname "$fx1")

set -l fx2 (gfp_make_fixture)
pushd "$fx2" >/dev/null
git fetch origin --prune --quiet
gfetchprune --include-untracked-dirty --execute >/dev/null
set -l left2 (git worktree list --porcelain | grep '^branch ' | string replace 'branch refs/heads/' '')
gfp_assert "include-untracked-dirty で merged-untracked worktree 削除" "not contains feat/merged-untracked $left2"
popd >/dev/null
rm -rf (dirname "$fx2")

set -l fx3 (gfp_make_fixture)
pushd "$fx3" >/dev/null
git fetch origin --prune --quiet
# gone-unmerged の worktree を tracked-dirty にする(既存の追跡ファイルを変更)
echo dirty-change >"$fx3/../wt/gone-unmerged/base.txt"
gfetchprune --include-gone-unmerged --execute >/dev/null
set -l left3 (git worktree list --porcelain | grep '^branch ' | string replace 'branch refs/heads/' '')
gfp_assert "dirty な gone worktree は force されず残る" "contains feat/gone-unmerged $left3"
set -l brs3 (git branch --format='%(refname:short)')
gfp_assert "dirty gone worktree の branch も残る(削除されない)" "contains feat/gone-unmerged $brs3"
popd >/dev/null
rm -rf (dirname "$fx3")

# PR 再判定: GitHub への問い合わせを差し替えて判定ロジックだけを検証する
functions -c __gfp_fetch_prs __gfp_fetch_prs_orig
set -l fx4 (gfp_make_fixture)
pushd "$fx4" >/dev/null
git fetch origin --prune --quiet
set -g GFP_PR_UNMERGED_TIP (git rev-parse feat/unmerged-pushed)
set -g GFP_PR_MAIN_TIP (git rev-parse main)
function __gfp_fetch_prs
    printf '%s\t%s\t%s\t%s\t%s\n' feat/unmerged-pushed 101 MERGED $GFP_PR_UNMERGED_TIP main
    printf '%s\t%s\t%s\t%s\t%s\n' feat/gone-unmerged 102 MERGED $GFP_PR_MAIN_TIP main
    printf '%s\t%s\t%s\t%s\t%s\n' feat/gone-unmerged 103 CLOSED $GFP_PR_MAIN_TIP main
end
set -l prow (__gfp_apply_pr_state main (__gfp_classify main refs/remotes/origin/main))
gfp_assert "tip を含む MERGED PR がある未マージ branch は delete-branch" test (gfp_cat_of feat/unmerged-pushed $prow) = delete-branch
gfp_assert "tip を含まない MERGED PR しか無い gone は confirm-gone のまま" test (gfp_cat_of feat/gone-unmerged $prow) = confirm-gone
set -l gone_row (string match -e 'feat/gone-unmerged' -- $prow)
gfp_assert "confirm-gone に PR 状態を併記" "string match -q '*#102 MERGED(tip が PR head に含まれない)*#103 CLOSED*' -- '$gone_row'"

function __gfp_fetch_prs
    printf '%s\t%s\t%s\t%s\t%s\n' feat/unmerged-pushed 104 MERGED $GFP_PR_UNMERGED_TIP feat/parent
end
set -l prow_stack (__gfp_apply_pr_state main (__gfp_classify main refs/remotes/origin/main))
gfp_assert "base が default 以外の MERGED は根拠にしない" test (gfp_cat_of feat/unmerged-pushed $prow_stack) = keep-unmerged

function __gfp_fetch_prs
    return 1
end
set -l base_rows (__gfp_classify main refs/remotes/origin/main)
set -l prow_fail (__gfp_apply_pr_state main $base_rows 2>/dev/null)
gfp_assert "PR 取得失敗時は分類を変えない" test (string join \n $prow_fail | string collect) = (string join \n $base_rows | string collect)

__gfp_delete_branch feat/unmerged-pushed refs/remotes/origin/main 0 $GFP_PR_MAIN_TIP >/dev/null
gfp_assert "PR 判定後に tip が変わった branch は削除しない" "contains feat/unmerged-pushed (git branch --format='%(refname:short)')"

function __gfp_fetch_prs
    printf '%s\t%s\t%s\t%s\t%s\n' feat/unmerged-pushed 101 MERGED $GFP_PR_UNMERGED_TIP main
end
gfetchprune --execute >/dev/null
gfp_assert "PR マージ済みの未マージ branch は --execute で削除" "not contains feat/unmerged-pushed (git branch --format='%(refname:short)')"
popd >/dev/null
rm -rf (dirname "$fx4")
functions -e __gfp_fetch_prs
functions -c __gfp_fetch_prs_orig __gfp_fetch_prs
set -e GFP_PR_UNMERGED_TIP GFP_PR_MAIN_TIP

rm -rf (dirname "$GFP_WORK")
test $GFP_FAILS -eq 0
