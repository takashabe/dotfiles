#!/usr/bin/env fish
source (status dirname)/../../.config/fish/gfetchprune.fish
source (status dirname)/fixture.fish

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

rm -rf (dirname "$GFP_WORK")
test $GFP_FAILS -eq 0
