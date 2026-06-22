set -g gfp_protect_branches main master stg qa dev develop staging production prod
set -g gfp_protect_worktree_paths '*/.wkit-worktrees/review'

function __gfp_is_protected_path --argument-names path
    for pat in $gfp_protect_worktree_paths $PROTECT_WORKTREE_PATHS
        if string match -q -- $pat $path
            return 0
        end
    end
    return 1
end

function __gfp_is_protected_branch --argument-names branch
    test -z "$branch"; and return 1
    if contains -- $branch $gfp_protect_branches $PROTECT_BRANCHES
        return 0
    end
    if string match -q 'release/*' -- $branch
        return 0
    end
    return 1
end

function __gfp_default_branch
    set -l d (git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | string replace 'origin/' '')
    if test -n "$d"
        echo $d
        return 0
    end
    for cand in main master
        if git show-ref --verify --quiet "refs/remotes/origin/$cand"
            echo $cand
            return 0
        end
    end
    return 1
end

function __gfp_merge_target --argument-names default
    set -l ref "refs/remotes/origin/$default"
    if git show-ref --verify --quiet $ref
        echo $ref
        return 0
    end
    return 1
end

function __gfp_worktree_dirty_kind --argument-names path
    set -l st (git -C $path status --porcelain 2>/dev/null)
    if test -z "$st"
        echo clean
        return 0
    end
    # tracked 変更/staged が 1 つでもあれば tracked(作業中)。すべて untracked(??)なら untracked。
    for line in $st
        if not string match -qr '^\?\?' -- $line
            echo tracked
            return 0
        end
    end
    echo untracked
end

function __gfp_branch_meta
    git for-each-ref --format='%(refname:short)|%(upstream:short)|%(upstream:track)|%(objectname)' refs/heads \
        | string replace -a '|' (printf '\t')
end

function __gfp_classify --argument-names default merge_target
    set -l current_wt (git rev-parse --show-toplevel)

    # worktree 一覧をパース: path \t branch(detached は空)
    set -l wt_paths
    set -l wt_branches
    set -l p ""
    set -l b ""
    for line in (git worktree list --porcelain)
        if string match -q 'worktree *' -- $line
            if test -n "$p"
                set -a wt_paths $p
                set -a wt_branches $b
            end
            set p (string replace 'worktree ' '' -- $line)
            set b ""
        else if string match -q 'branch refs/heads/*' -- $line
            set b (string replace 'branch refs/heads/' '' -- $line)
        end
    end
    if test -n "$p"
        set -a wt_paths $p
        set -a wt_branches $b
    end

    # ブランチメタを連想引き用に展開
    set -l meta_branch
    set -l meta_up
    set -l meta_track
    for m in (__gfp_branch_meta)
        set -l f (string split \t -- $m)
        set -a meta_branch $f[1]
        set -a meta_up $f[2]
        set -a meta_track $f[3]
    end

    set -l seen_branches

    # pass 1: worktree を持つエントリ
    for i in (seq (count $wt_paths))
        set -l path $wt_paths[$i]
        set -l branch $wt_branches[$i]

        if test -z "$branch"
            printf '%s\t%s\t%s\t%s\n' detached '-' $path 'detached HEAD'
            continue
        end
        set -a seen_branches $branch

        if test "$path" = "$current_wt"
            printf '%s\t%s\t%s\t%s\n' skip-current $branch $path ''
            continue
        end
        if test "$branch" = "$default"
            printf '%s\t%s\t%s\t%s\n' protect-branch $branch $path 'default'
            continue
        end
        if __gfp_is_protected_branch $branch
            printf '%s\t%s\t%s\t%s\n' protect-branch $branch $path ''
            continue
        end
        if __gfp_is_protected_path $path
            printf '%s\t%s\t%s\t%s\n' protect-path $branch $path ''
            continue
        end

        __gfp_emit_decision $branch $path $merge_target wt
    end

    # pass 2: worktree を持たないブランチ
    for i in (seq (count $meta_branch))
        set -l branch $meta_branch[$i]
        contains -- $branch $seen_branches; and continue
        test "$branch" = "$default"; and continue
        if __gfp_is_protected_branch $branch
            printf '%s\t%s\t%s\t%s\n' protect-branch $branch '-' ''
            continue
        end
        __gfp_emit_decision $branch '-' $merge_target nowt
    end
end

# merged/pushed/gone と dirty を評価して 1 行 emit する
function __gfp_emit_decision --argument-names branch path merge_target kind
    set -l up ""
    set -l track ""
    for m in (__gfp_branch_meta)
        set -l f (string split \t -- $m)
        if test "$f[1]" = "$branch"
            set up $f[2]
            set track $f[3]
            break
        end
    end
    set -l gone 0
    string match -q '*gone*' -- $track; and set gone 1
    set -l pushed 0
    if test -n "$up" -o $gone -eq 1
        set pushed 1
    end
    set -l merged 0
    git merge-base --is-ancestor $branch $merge_target 2>/dev/null; and set merged 1

    if test $merged -eq 0
        if test $gone -eq 1
            set -l n (git rev-list --count $merge_target..$branch 2>/dev/null)
            printf '%s\t%s\t%s\t%s\n' confirm-gone $branch $path "unique=$n"
        else
            printf '%s\t%s\t%s\t%s\n' keep-unmerged $branch $path ''
        end
        return
    end
    # merged
    if test $pushed -eq 0
        printf '%s\t%s\t%s\t%s\n' protect-nopush $branch $path ''
        return
    end
    # merged + pushed: worktree があれば dirty を評価
    if test "$kind" = wt
        set -l dk (__gfp_worktree_dirty_kind $path)
        if test "$dk" = tracked
            printf '%s\t%s\t%s\t%s\n' skip-dirty $branch $path tracked
            return
        else if test "$dk" = untracked
            printf '%s\t%s\t%s\t%s\n' confirm-untracked $branch $path untracked
            return
        end
        printf '%s\t%s\t%s\t%s\n' delete-wt $branch $path ''
    else
        printf '%s\t%s\t%s\t%s\n' delete-branch $branch $path ''
    end
end

function gfetchprune --description 'push済み・マージ済みの worktree/branch を安全に掃除する(既定 dry-run、--execute で実削除)'
    set -l explicit_dry 0
    set -l execute 0
    set -l include_gone 0
    set -l include_untracked 0
    for arg in $argv
        switch $arg
            case --execute -x
                set execute 1
            case --dry-run -n
                set explicit_dry 1
            case --include-gone-unmerged
                set include_gone 1
            case --include-untracked-dirty
                set include_untracked 1
            case '*'
                echo "Usage: gfetchprune [--execute|-x] [--dry-run|-n] [--include-gone-unmerged] [--include-untracked-dirty]"
                return 1
        end
    end
    # dry-run 優先: -n が明示されていれば --execute を無効化する
    set -l do_execute 0
    if test $execute -eq 1 -a $explicit_dry -eq 0
        set do_execute 1
    end

    if not git rev-parse --show-toplevel >/dev/null 2>&1
        echo "not a git repository"
        return 1
    end

    set -l default (__gfp_default_branch)
    if test -z "$default"
        echo "default branch not found. try: git remote set-head origin --auto"
        return 1
    end
    set -l merge_target (__gfp_merge_target $default)
    if test -z "$merge_target"
        echo "origin/$default not found. try: git remote set-head origin --auto && git fetch origin"
        return 1
    end

    if not git fetch origin --prune
        echo "git fetch origin --prune failed: aborting"
        return 1
    end

    # 後続タスクで classify / render / execute を追加する
    return 0
end
