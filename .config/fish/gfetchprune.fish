# gfetchprune: カレント repo の push 済み・マージ済み worktree/branch を安全に掃除する。
# 対象: git worktree list に出る全 worktree(git wt 管理下 ../.worktrees/{gitroot} を含む)。
# 既定 dry-run。実削除は --execute。
# 保護: ブランチ=gfp_protect_branches(repo 既定) + PROTECT_BRANCHES(完全一致で追加)。
#       worktree パス=PROTECT_WORKTREE_PATHS のみ(パスは環境固有のため repo 既定なし)。
# 設定例(local.fish): set -g PROTECT_BRANCHES my-keep-branch ; set -g PROTECT_WORKTREE_PATHS '*/sandbox' '*/persistent/*'
# push 無の merged は「作ったばかりでまだコミットしていない」ものを守るため保護する。ただしブランチと worktree
#   HEAD の reflog の最終更新が GFP_STALE_DAYS(既定 7)日より前なら放置とみなして削除対象に戻す。reflog の無い
#   worktree は経過日数を判断できないため保護のままにする(reflog は gc.reflogExpire で消えるため、長く放置した
#   worktree はこの保護に戻りうる)。
# squash/rebase merge は origin/default の祖先にならないため、未マージ・gone は GitHub の PR で再判定する。
#   default ブランチ向けに MERGED で、ローカル tip が PR head に含まれるものだけを削除対象にする。
#   origin が github.com 以外、gh が無い・失敗した場合は再判定せず祖先判定だけで分類する。
# 既知制限: --include-gone-unmerged は worktree を持つ gone ブランチのみ削除する。worktree なしの gone ブランチは
#   dry-run で表示されるが削除しない(誤削除回避のためデータを保持する方向に倒している)。

set -g gfp_protect_branches main master stg qa dev develop staging production prod
set -g gfp_stale_days_default 7
set -g gfp_pr_chunk 50
set -g gfp_pr_timeout 15
# worktree パスは環境固有のため repo 既定を持たない。マシンごとに local.fish で
# PROTECT_WORKTREE_PATHS を設定する(例: set -g PROTECT_WORKTREE_PATHS '*/sandbox')。
set -g gfp_protect_worktree_paths

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
    for line in $st
        if not string match -qr '^\?\?' -- $line
            echo tracked
            return 0
        end
    end
    echo untracked
end

function __gfp_branch_meta
    # for-each-ref は --format 内の \t をタブに展開しないため、実タブを変数で埋め込む
    set -l tab (printf '\t')
    git for-each-ref --format="%(refname:short)$tab%(upstream:short)$tab%(upstream:track)$tab%(objectname)" refs/heads
end

function __gfp_classify --argument-names default merge_target
    set -l current_wt (git rev-parse --show-toplevel)

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

        set -l up ""
        set -l track ""
        for j in (seq (count $meta_branch))
            if test "$meta_branch[$j]" = "$branch"
                set up $meta_up[$j]
                set track $meta_track[$j]
                break
            end
        end
        __gfp_emit_decision $branch $path $merge_target wt $up $track
    end

    for i in (seq (count $meta_branch))
        set -l branch $meta_branch[$i]
        contains -- $branch $seen_branches; and continue
        test "$branch" = "$default"; and continue
        if __gfp_is_protected_branch $branch
            printf '%s\t%s\t%s\t%s\n' protect-branch $branch '-' ''
            continue
        end
        set -l up $meta_up[$i]
        set -l track $meta_track[$i]
        __gfp_emit_decision $branch '-' $merge_target nowt $up $track
    end
end

# merged/pushed/gone と dirty を評価して 1 行 emit する
function __gfp_emit_decision --argument-names branch path merge_target kind up track
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
    set -l note ''
    if test $pushed -eq 0
        set -l idle (__gfp_idle_days $branch $path)
        if test -z "$idle"
            if test "$kind" = wt
                printf '%s\t%s\t%s\t%s\n' protect-nopush $branch $path 'reflog なし'
                return
            end
            # worktree も固有コミットも無いので、消えるのはブランチ名だけ
            set note 'reflog なし'
        else if test $idle -lt (__gfp_stale_days)
            printf '%s\t%s\t%s\t%s\n' protect-nopush $branch $path "最終更新 $idle 日前"
            return
        else
            set note "最終更新 $idle 日前"
        end
    end
    __gfp_emit_removal $branch $path $kind $note ''
end

# 削除してよいと判定済みのブランチを、worktree の dirty 状態に応じて削除系カテゴリへ振り分ける。
# pr_oid は PR 判定時点の tip。実削除の直前に tip が動いていないかの再確認に使う。
function __gfp_emit_removal --argument-names branch path kind note pr_oid
    if test "$kind" = wt
        set -l dk (__gfp_worktree_dirty_kind $path)
        if test "$dk" = tracked
            printf '%s\t%s\t%s\t%s\t%s\n' skip-dirty $branch $path (string trim -- "tracked $note") $pr_oid
            return
        else if test "$dk" = untracked
            printf '%s\t%s\t%s\t%s\t%s\n' confirm-untracked $branch $path (string trim -- "untracked $note") $pr_oid
            return
        end
        printf '%s\t%s\t%s\t%s\t%s\n' delete-wt $branch $path $note $pr_oid
    else
        printf '%s\t%s\t%s\t%s\t%s\n' delete-branch $branch $path $note $pr_oid
    end
end

function __gfp_stale_days
    if string match -qr '^\d+$' -- "$GFP_STALE_DAYS"
        echo $GFP_STALE_DAYS
    else
        echo $gfp_stale_days_default
    end
end

# 最終更新からの経過日数。どの reflog も無ければ何も出さない。
# worktree add / switch はブランチ reflog を更新せず worktree の HEAD reflog にだけ残るため、
# 古いブランチを最近 worktree に出した場合を拾うには両方の新しいほうを見る必要がある。
# worktree の index mtime は git status で更新されるため、放置期間の判定には使えない。
function __gfp_idle_days --argument-names branch path
    set -l stamps (__gfp_reflog_ts git reflog show --date=unix -1 --format=%gd refs/heads/$branch --)
    if test -n "$path" -a "$path" != '-'
        set -a stamps (__gfp_reflog_ts git -C $path reflog show --date=unix -1 --format=%gd HEAD --)
    end
    test (count $stamps) -gt 0; or return 0
    math -s0 "("(date +%s)" - max("(string join , $stamps)")) / 86400"
end

function __gfp_reflog_ts
    set -l sel ($argv 2>/dev/null)
    string match -rg '@\{(\d+)\}$' -- $sel
end

function __gfp_github_repo
    set -l url (git remote get-url origin 2>/dev/null)
    string match -rg '^(?:https://|ssh://git@|git@)github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?/?$' -- $url
end

# 引数のブランチを head に持つ PR を「branch\tnumber\tstate\theadRefOid\tbaseRefName」で出力する。
# 対象外(origin が github.com でない・gh が無い)は 2、問い合わせ失敗は 1 を返す。
function __gfp_fetch_prs
    test (count $argv) -gt 0; or return 0
    command -q gh; or return 2
    set -l repo (__gfp_github_repo)
    test (count $repo) -eq 2; or return 2

    # gh は応答待ちで無期限に止まりうるため、timeout があれば上限を付ける
    set -l limiter command
    command -q timeout; and set limiter timeout $gfp_pr_timeout

    set -l total (count $argv)
    set -l start 1
    while test $start -le $total
        set -l stop (math "min($start + $gfp_pr_chunk - 1, $total)")
        set -l decls '$owner:String!' '$name:String!'
        set -l fields
        set -l vars -f owner=$repo[1] -f name=$repo[2]
        for i in (seq $start $stop)
            # ブランチ名は GraphQL 変数で渡し、クエリ文字列には埋め込まない
            set -a decls "\$h$i:String!"
            set -a fields "b$i:pullRequests(headRefName:\$h$i,first:5,orderBy:{field:CREATED_AT,direction:DESC}){nodes{number state headRefOid baseRefName}}"
            set -a vars -f "h$i=$argv[$i]"
        end
        set -l query "query("(string join , $decls)"){repository(owner:\$owner,name:\$name){"(string join ' ' $fields)"}}"
        set -l lines ($limiter gh api graphql -f query=$query $vars \
            --jq '.data.repository | to_entries[] | .key as $k | .value.nodes[] | [$k, (.number|tostring), .state, .headRefOid, .baseRefName] | @tsv' 2>/dev/null)
        or return 1
        for l in $lines
            set -l f (string split \t -- $l)
            set -l idx (string sub -s 2 -- $f[1])
            printf '%s\t%s\t%s\t%s\t%s\n' $argv[$idx] $f[2] $f[3] $f[4] $f[5]
        end
        set start (math $stop + 1)
    end
end

# 祖先判定で未マージ・gone になった行を PR で再判定する。squash/rebase merge で取り込まれた
# ブランチは祖先にならないため、PR head がローカル tip を含むことを取り込み済みの根拠にする。
# base が default 以外(スタック PR など)の MERGED は default に届いた保証がないので根拠にしない。
function __gfp_apply_pr_state --argument-names default
    set -l rows $argv[2..-1]
    set -l cands
    for r in $rows
        set -l f (string split \t -- $r)
        contains -- $f[1] keep-unmerged confirm-gone; and set -a cands $f[2]
    end
    set -l prs
    if test (count $cands) -gt 0
        set prs (__gfp_fetch_prs $cands)
        set -l st $status
        if test $st -ne 0
            test $st -eq 1; and echo "注意: PR 状態を取得できなかったため、squash/rebase merge の再判定をスキップしました" >&2
            printf '%s\n' $rows
            return 0
        end
    end

    for r in $rows
        set -l f (string split \t -- $r)
        if not contains -- $f[1] keep-unmerged confirm-gone
            printf '%s\n' $r
            continue
        end
        set -l br $f[2]
        set -l path $f[3]
        set -l tip (git rev-parse --verify --quiet refs/heads/$br)
        set -l proof ''
        set -l labels
        for p in $prs
            set -l q (string split \t -- $p)
            test "$q[1]" = "$br"; or continue
            if test "$q[3]" = MERGED -a "$q[5]" = "$default" -a -n "$tip"
                if git merge-base --is-ancestor $tip $q[4] 2>/dev/null
                    set proof $q[2]
                    break
                end
                set -a labels "#$q[2] MERGED(tip が PR head に含まれない)"
            else if test "$q[3]" = MERGED
                set -a labels "#$q[2] MERGED→$q[5]"
            else
                set -a labels "#$q[2] $q[3]"
            end
        end
        if test -n "$proof"
            set -l kind wt
            test "$path" = '-'; and set kind nowt
            __gfp_emit_removal $br $path $kind "PR #$proof merged" $tip
            continue
        end
        printf '%s\t%s\t%s\t%s\n' $f[1] $br $path (string trim -- "$f[4] "(string join ', ' $labels))
    end
end

# rows のうち category=cat の行を見出し付きで表示する(rows は末尾可変長で受ける)
function __gfp_section --argument-names title cat
    set -l hits
    for r in $argv[3..-1]
        set -l f (string split \t -- $r)
        test "$f[1]" = "$cat"; and set -a hits "  $f[2]  ($f[3])  $f[4]"
    end
    if test (count $hits) -gt 0
        echo "$title: "(count $hits)
        printf '%s\n' $hits
    end
end

function __gfp_render
    set -l rows $argv
    __gfp_section "削除予定 worktree" delete-wt $rows
    __gfp_section "削除予定 branch(worktree なし)" delete-branch $rows
    __gfp_section "要確認: gone-only(リモート削除済み・未マージ固有コミットあり) [--include-gone-unmerged]" confirm-gone $rows
    __gfp_section "要確認: untracked のみ dirty [--include-untracked-dirty]" confirm-untracked $rows
    __gfp_section "保護(push 無の merged、最終更新から "(__gfp_stale_days)" 日未満) [GFP_STALE_DAYS]" protect-nopush $rows
    __gfp_section "スキップ: 保護ブランチ" protect-branch $rows
    __gfp_section "スキップ: 保護パス" protect-path $rows
    __gfp_section "スキップ: dirty(作業中)" skip-dirty $rows
    __gfp_section "スキップ: カレント worktree" skip-current $rows
    __gfp_section "detached(手動確認推奨)" detached $rows
    __gfp_section "残す: 未マージ" keep-unmerged $rows
    echo "注意: worktree 削除時、git wt がコピーした .env.local 等の ignored ファイルも一緒に消えます。"
end

function __gfp_execute --argument-names merge_target include_gone include_untracked
    set -l rows $argv[4..-1]
    set -l removed_branches

    for r in $rows
        set -l f (string split \t -- $r)
        set -l cat $f[1]; set -l br $f[2]; set -l path $f[3]; set -l oid $f[5]
        set -l do 0
        test "$cat" = delete-wt; and set do 1
        test "$cat" = confirm-untracked -a "$include_untracked" = 1; and set do 1
        test "$cat" = confirm-gone -a "$include_gone" = 1; and set do 1
        test $do -eq 1; or continue

        set -l force_flag
        # confirm-untracked は untracked のみ確定済みで --include-untracked-dirty で明示同意済み。
        # confirm-gone は dirty 未確認(tracked 変更が残りうる)ため force せず、git の拒否を安全弁にする。
        if test "$cat" = confirm-untracked
            set force_flag --force
        end
        if git worktree remove $force_flag $path
            set -a removed_branches (printf '%s\t%s\t%s' $br $cat "$oid")
        else
            echo "skip(remove 失敗): $path"
        end
    end

    for r in $rows
        set -l f (string split \t -- $r)
        set -l cat $f[1]; set -l br $f[2]
        test "$cat" = delete-branch; or continue
        __gfp_delete_branch $br $merge_target 0 "$f[5]"
    end
    for rb in $removed_branches
        set -l p (string split \t -- $rb)
        set -l br $p[1]; set -l cat $p[2]
        set -l gone_flag 0
        test "$cat" = confirm-gone; and set gone_flag 1
        __gfp_delete_branch $br $merge_target $gone_flag "$p[3]"
    end
end

# is-ancestor を削除直前に再確認してから -d→-D。gone-only(gone_flag=1)は -D 直行。
# PR 判定で削除対象になったもの(pr_oid あり)は祖先にならないため、tip が判定時から動いていないことを確認して -D。
function __gfp_delete_branch --argument-names branch merge_target gone_flag pr_oid
    if test -n "$pr_oid"
        set -l now_tip (git rev-parse --verify --quiet refs/heads/$branch)
        if test "$now_tip" != "$pr_oid"
            echo "skip(PR 判定後に tip が変わった): $branch"
            return
        end
        git branch -D $branch
        return
    end
    if test "$gone_flag" = 1
        git branch -D $branch
        return
    end
    if not git merge-base --is-ancestor $branch $merge_target 2>/dev/null
        echo "skip(再検証で未マージ): $branch"
        return
    end
    if git branch -d $branch 2>/dev/null
        return
    end
    # -d は HEAD 基準で誤拒否しうる。origin merged は再確認済みなので -D。
    echo "merged 確認済みのため -D: $branch"
    git branch -D $branch
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

    set -l rows (__gfp_apply_pr_state $default (__gfp_classify $default $merge_target))

    if test (count $rows) -eq 0
        echo "already updated"
        return 0
    end

    if test $do_execute -eq 0
        __gfp_render $rows
        echo ""
        echo "実削除するには: gfetchprune --execute"
        return 0
    end

    __gfp_execute $merge_target $include_gone $include_untracked $rows
    return 0
end
