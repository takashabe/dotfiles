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
    git for-each-ref --format='%(refname:short)\t%(upstream:short)\t%(upstream:track)\t%(objectname)' refs/heads
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
