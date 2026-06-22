# gfetchprune worktree/branch 掃除コマンド Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `gfetchprune` を、push 済みかつマージ済みの worktree/branch だけを安全に掃除する dry-run 既定コマンドへ進化させる。

**Architecture:** 既存の単一 fish 関数を `~/dotfiles/.config/fish/gfetchprune.fish`(スタンドアロン)に切り出し、symlink 済みの `config.fish` から絶対パスで `source` する。責務ごとの `__gfp_*` ヘルパへ分解する。中核は「分類関数 `__gfp_classify`(各 worktree/branch をカテゴリ付きの行に変換)」で、dry-run は分類結果を整形表示し、`--execute` は分類結果を安全に削除実行する。検証は使い捨ての fixture git リポジトリに対して行う。

**Tech Stack:** fish shell, git(worktree/for-each-ref/merge-base)。テストは fish スクリプト + 一時 git リポジトリ。

## Global Constraints

- 対象シェル: fish。実装ファイルは `~/dotfiles/.config/fish/gfetchprune.fish`(symlink 済みの `config.fish` が絶対パスで `source` する。`conf.d/` は symlink されていないため使わない)。
- 既定は **dry-run**。実削除は `--execute`/`-x` のみ。`-n`/`--dry-run` と同時指定時は **dry-run 優先**。
- 削除述語: `is-ancestor(B, origin/<default>)` が真 **かつ** push 済み(`upstream` あり または `track==[gone]`)**かつ** clean **かつ** 非保護。
- gone 判定は `%(upstream:track)`(=`[gone]`)で行う。`%(upstream:trackshort)` は使わない(現行バグ)。
- gone-only(`is-ancestor=false` かつ gone)は自動削除しない(`--include-gone-unmerged` 指定時のみ)。
- upstream 無し merged は削除しない(push 済み条件で保護)。
- ハードコード保護ブランチ: `main master stg qa dev develop staging production prod` + `release/*` 前方一致。`PROTECT_BRANCHES` は追加(完全一致 `contains`)。
- 保護パス既定: `*/.wkit-worktrees/review`。`PROTECT_WORKTREE_PATHS` は追加(glob)。
- worktree 削除は `git worktree remove`(`-f` なし)。branch 削除は `-d`→拒否時に is-ancestor 再確認のうえ `-D`。順序は worktree 先 → branch 後。
- `git fetch origin --prune` 失敗時は `return 1`(fail-fast)。
- `merge_target` は `refs/remotes/origin/<default>` 必須。無ければ `git remote set-head origin --auto` を案内してエラー終了(ローカルフォールバックは安全性のため行わない — spec から強化)。
- テストは `~/dotfiles/test/gfetchprune/` 配下。本物の作業リポジトリは変更しない。

---

## ファイル構成

- Create: `~/dotfiles/.config/fish/gfetchprune.fish` — `gfetchprune` 本体と `__gfp_*` ヘルパ群。
- Modify: `~/dotfiles/.config/fish/config.fish:85-237` — 旧 `gfetchprune` 関数を削除し、末尾に `source $HOME/dotfiles/.config/fish/gfetchprune.fish` を追加。
- Create: `~/dotfiles/test/gfetchprune/fixture.fish` — 既知状態の一時 git リポジトリを生成し、その work パスを echo する。
- Create: `~/dotfiles/test/gfetchprune/run.fish` — fixture に対して assertion を実行するテストランナ。

### ヘルパの責務と interface

- `__gfp_default_branch` → stdout: default ブランチ短名。exit 1 で解決不能。
- `__gfp_merge_target <default>` → stdout: `refs/remotes/origin/<default>`。exit 1 で不在。
- `__gfp_branch_meta` → stdout: 各ローカルブランチ 1 行 `branch\tupstream\ttrack\tobjectname`(タブ区切り)。
- `__gfp_is_protected_branch <branch>` → exit 0=保護。
- `__gfp_is_protected_path <path>` → exit 0=保護。
- `__gfp_worktree_dirty_kind <path>` → stdout: `clean` | `tracked` | `untracked`。
- `__gfp_classify <default> <merge_target>` → stdout: 候補ごと 1 行 `category\tbranch\tpath\tdetail`。
- `gfetchprune [flags]` → 引数解析 → fetch fail-fast → classify →(dry-run 表示 | execute 削除)。

カテゴリ語彙: `delete-wt` `delete-branch` `confirm-gone` `confirm-untracked` `protect-nopush` `protect-branch` `protect-path` `skip-current` `skip-dirty` `detached` `keep-unmerged`。

---

## Task 1: テストハーネスと関数スケルトン(引数解析)

**Files:**
- Create: `~/dotfiles/.config/fish/gfetchprune.fish`
- Create: `~/dotfiles/test/gfetchprune/fixture.fish`
- Create: `~/dotfiles/test/gfetchprune/run.fish`
- Modify: `~/dotfiles/.config/fish/config.fish:85-237`

**Interfaces:**
- Produces: `gfetchprune` の引数解析(`dry_run`/`do_execute`/`include_gone`/`include_untracked` の決定)。`gfp_make_fixture` → work リポジトリパスを echo。`gfp_assert <desc> <cmd...>` 相当の assertion。

- [ ] **Step 1: fixture ビルダを書く**

`~/dotfiles/test/gfetchprune/fixture.fish`:

```fish
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
    echo "$name" >"$work/$name-file.txt"
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
```

- [ ] **Step 2: テストランナのスケルトンを書く**

`~/dotfiles/test/gfetchprune/run.fish`:

```fish
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

rm -rf (dirname "$GFP_WORK")  # = mktemp の $root。dirname を2回かけると $TMPDIR ルートを消すので1回
test $GFP_FAILS -eq 0
```

- [ ] **Step 3: gfetchprune スケルトンを実装(引数解析のみ)**

`~/dotfiles/.config/fish/gfetchprune.fish`:

```fish
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

    # 後続タスクで fetch / classify / render / execute を追加する
    return 0
end
```

- [ ] **Step 4: 旧 gfetchprune を config.fish から削除し source 行を追加**

`~/dotfiles/.config/fish/config.fish` の 85-237 行(コメント行 `# ルート/ワークツリー双方で…` から関数末尾 `end` まで)を削除する。前後の `gpull` 関数(81-83 行)と `# ブランチ一覧をfzfで…`(239 行〜)は残す。
削除した位置に、新ファイルを読み込む 1 行を追加する:

```fish
source $HOME/dotfiles/.config/fish/gfetchprune.fish
```

(`config.fish` は `~/.config/fish/config.fish` へ symlink 済みで全シェル起動時に読まれる。絶対パス source なので確実にライブ反映される。`conf.d/` は dotfiles 管理外のため使わない。)

- [ ] **Step 5: テスト実行(失敗→通過を確認)**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 3 つの assertion がすべて `ok`、終了コード 0。

- [ ] **Step 6: Commit**

```bash
git add .config/fish/gfetchprune.fish .config/fish/config.fish test/gfetchprune/
git commit -m "feat(fish): gfetchprune を専用ファイルへ切り出し dry-run 既定の引数解析を追加"
```

---

## Task 2: default ブランチと merge_target の解決

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`
- Modify: `~/dotfiles/test/gfetchprune/run.fish`

**Interfaces:**
- Produces: `__gfp_default_branch`(stdout 短名/exit1)、`__gfp_merge_target <default>`(stdout ref/exit1)。

- [ ] **Step 1: 失敗するテストを追記(run.fish の `rm -rf` 行の前に)**

```fish
gfp_assert "default branch は main" test (__gfp_default_branch) = main
gfp_assert "merge_target は origin/main" test (__gfp_merge_target main) = refs/remotes/origin/main
gfp_assert "merge_target 不在は exit1" "not __gfp_merge_target nonexistent >/dev/null 2>&1"
```

- [ ] **Step 2: テスト実行で失敗を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 新規 3 件が `FAIL`(関数未定義)。

- [ ] **Step 3: ヘルパを実装(gfetchprune 定義の前に追加)**

```fish
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
```

- [ ] **Step 4: gfetchprune に default 解決と fail を組み込む(`return 0` の直前を置換)**

`return 0` の行を次に置換:

```fish
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

    # 後続タスクで fetch / classify / render / execute を追加する
    return 0
```

- [ ] **Step 5: テスト実行で通過を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`、終了コード 0。

- [ ] **Step 6: Commit**

```bash
git add .config/fish/gfetchprune.fish test/gfetchprune/run.fish
git commit -m "feat(fish): gfetchprune に default/merge_target の堅牢な解決を追加"
```

---

## Task 3: fetch fail-fast

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`
- Modify: `~/dotfiles/test/gfetchprune/run.fish`

**Interfaces:**
- Consumes: Task 2 の default/merge_target。
- Produces: `gfetchprune` が fetch 失敗時に `return 1`。

- [ ] **Step 1: 失敗するテストを追記(`rm -rf` の前)**

```fish
# origin を壊して fetch 失敗時に exit1 することを確認(別 fixture)
set -l broken (gfp_make_fixture)
git -C "$broken" remote set-url origin /nonexistent/path.git
pushd "$broken" >/dev/null
gfp_assert "fetch 失敗で exit1" "not gfetchprune >/dev/null 2>&1"
popd >/dev/null
rm -rf (dirname "$broken")
```

- [ ] **Step 2: テスト実行で失敗を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 「fetch 失敗で exit1」が `FAIL`(まだ fetch していない)。

- [ ] **Step 3: fetch fail-fast を実装(merge_target 解決ブロックの直後に追加)**

Task 2 で置いた `# 後続タスクで…` コメント行の前に挿入:

```fish
    if not git fetch origin --prune
        echo "git fetch origin --prune failed: aborting"
        return 1
    end
```

- [ ] **Step 4: テスト実行で通過を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`。

- [ ] **Step 5: Commit**

```bash
git add .config/fish/gfetchprune.fish test/gfetchprune/run.fish
git commit -m "feat(fish): gfetchprune に fetch fail-fast を追加"
```

---

## Task 4: ブランチメタの一括取得と gone 判定

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`
- Modify: `~/dotfiles/test/gfetchprune/run.fish`

**Interfaces:**
- Produces: `__gfp_branch_meta` → `branch\tupstream\ttrack\tobjectname` の行群。gone は `track` に `gone` を含む。

- [ ] **Step 1: 失敗するテストを追記(`rm -rf` の前)**

```fish
# gone は track(長形式)で検出できる(trackshort では不可)
set -l gline (__gfp_branch_meta | string match -e 'feat/merged-gone')
gfp_assert "merged-gone の track が gone" "string match -q '*gone*' -- '$gline'"
set -l uline (__gfp_branch_meta | string match -e 'feat/unmerged-pushed')
gfp_assert "unmerged-pushed は gone でない" "not string match -q '*gone*' -- '$uline'"
```

- [ ] **Step 2: テスト実行で失敗を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 2 件 `FAIL`(関数未定義)。

- [ ] **Step 3: ヘルパを実装(他ヘルパの近くに追加)**

```fish
function __gfp_branch_meta
    # for-each-ref は --format 内の \t をタブに展開しないため、実タブを変数で埋め込む
    set -l tab (printf '\t')
    git for-each-ref --format="%(refname:short)$tab%(upstream:short)$tab%(upstream:track)$tab%(objectname)" refs/heads
end
```

- [ ] **Step 4: テスト実行で通過を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`。`for-each-ref` の `\t` がタブ展開されることも確認(`string match -e 'feat/merged-gone'` がヒット)。

- [ ] **Step 5: Commit**

```bash
git add .config/fish/gfetchprune.fish test/gfetchprune/run.fish
git commit -m "feat(fish): ブランチメタ一括取得と track ベースの gone 判定を追加"
```

---

## Task 5: ブランチ保護判定

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`
- Modify: `~/dotfiles/test/gfetchprune/run.fish`

**Interfaces:**
- Produces: グローバル `gfp_protect_branches`、`__gfp_is_protected_branch <branch>`(exit0=保護)。

- [ ] **Step 1: 失敗するテストを追記(`rm -rf` の前)**

```fish
gfp_assert "stg は保護" "__gfp_is_protected_branch stg"
gfp_assert "release/x は保護" "__gfp_is_protected_branch release/2026-q2"
gfp_assert "feat/foo は非保護" "not __gfp_is_protected_branch feat/foo"
# PROTECT_BRANCHES がリストでも完全一致で効く・空でも壊れない
set -l PROTECT_BRANCHES keepme other
gfp_assert "リスト PROTECT_BRANCHES が効く" "__gfp_is_protected_branch keepme"
set -e PROTECT_BRANCHES
gfp_assert "空 PROTECT_BRANCHES で誤保護しない" "not __gfp_is_protected_branch ''"
```

- [ ] **Step 2: テスト実行で失敗を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 関連 assertion が `FAIL`。

- [ ] **Step 3: 実装(ヘルパ群の近くに追加)**

```fish
set -g gfp_protect_branches main master stg qa dev develop staging production prod

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
```

- [ ] **Step 4: テスト実行で通過を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`。`contains` による完全一致でリスト/空/メタ文字いずれも安全。

- [ ] **Step 5: Commit**

```bash
git add .config/fish/gfetchprune.fish test/gfetchprune/run.fish
git commit -m "feat(fish): ハードコード既定 + PROTECT_BRANCHES のブランチ保護判定を追加"
```

---

## Task 6: worktree パス保護判定

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`
- Modify: `~/dotfiles/test/gfetchprune/run.fish`

**Interfaces:**
- Produces: グローバル `gfp_protect_worktree_paths`、`__gfp_is_protected_path <path>`(exit0=保護)。

- [ ] **Step 1: 失敗するテストを追記(`rm -rf` の前、`cd "$GFP_WORK"` 済みの文脈)**

```fish
gfp_assert "review パスは保護" "__gfp_is_protected_path $GFP_WORK/.git/.wkit-worktrees/review"
gfp_assert "通常 worktree は非保護" "not __gfp_is_protected_path /tmp/wt/merged-pushed"
```

- [ ] **Step 2: テスト実行で失敗を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: `FAIL`(関数未定義)。

- [ ] **Step 3: 実装(ヘルパ群の近くに追加)**

```fish
set -g gfp_protect_worktree_paths '*/.wkit-worktrees/review'

function __gfp_is_protected_path --argument-names path
    for pat in $gfp_protect_worktree_paths $PROTECT_WORKTREE_PATHS
        if string match -q -- $pat $path
            return 0
        end
    end
    return 1
end
```

- [ ] **Step 4: テスト実行で通過を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`。

- [ ] **Step 5: Commit**

```bash
git add .config/fish/gfetchprune.fish test/gfetchprune/run.fish
git commit -m "feat(fish): PROTECT_WORKTREE_PATHS(既定で review)のパス保護判定を追加"
```

---

## Task 7: worktree の dirty 種別判定

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`
- Modify: `~/dotfiles/test/gfetchprune/run.fish`

**Interfaces:**
- Produces: `__gfp_worktree_dirty_kind <path>` → `clean` | `tracked` | `untracked`。

**Note(spec からの精緻化):** git wt はコピーした gitignore 済みファイル(`.env.local` 等)を全 worktree に常時持つため「コピー ignored ファイルがあればスキップ」は全件スキップに退化する。よって dirty 判定は `git status --porcelain`(ignored 除外)に基づき、`clean`/`tracked`/`untracked` のみを返す。worktree 削除でコピーファイルが消える点は dry-run の総合注意として一度だけ表示する(Task 9)。

- [ ] **Step 1: 失敗するテストを追記(`rm -rf` の前)**

```fish
set -l root (dirname "$GFP_WORK")  # = mktemp の $root($GFP_WORK は $root/work)
gfp_assert "clean を判定" test (__gfp_worktree_dirty_kind "$root/wt/merged-pushed") = clean
gfp_assert "tracked 変更を判定" test (__gfp_worktree_dirty_kind "$root/wt/merged-dirty") = tracked
gfp_assert "untracked を判定" test (__gfp_worktree_dirty_kind "$root/wt/merged-untracked") = untracked
```

- [ ] **Step 2: テスト実行で失敗を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: `FAIL`(関数未定義)。

- [ ] **Step 3: 実装(ヘルパ群の近くに追加)**

```fish
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
```

- [ ] **Step 4: テスト実行で通過を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`。

- [ ] **Step 5: Commit**

```bash
git add .config/fish/gfetchprune.fish test/gfetchprune/run.fish
git commit -m "feat(fish): worktree の dirty 種別(clean/tracked/untracked)判定を追加"
```

---

## Task 8: 分類エンジン `__gfp_classify`

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`
- Modify: `~/dotfiles/test/gfetchprune/run.fish`

**Interfaces:**
- Consumes: Task 2,4,5,6,7 の全ヘルパ。
- Produces: `__gfp_classify <default> <merge_target>` → 候補ごと 1 行 `category\tbranch\tpath\tdetail`。worktree 無しブランチの path は `-`。

- [ ] **Step 1: 失敗するテストを追記(`rm -rf` の前)**

```fish
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
```

- [ ] **Step 2: テスト実行で失敗を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 9 件 `FAIL`(関数未定義)。

- [ ] **Step 3: `__gfp_classify` を実装**

```fish
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
```

- [ ] **Step 4: テスト実行で通過を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`。

- [ ] **Step 5: Commit**

```bash
git add .config/fish/gfetchprune.fish test/gfetchprune/run.fish
git commit -m "feat(fish): worktree/branch をカテゴリ分類する __gfp_classify を追加"
```

---

## Task 9: dry-run 表示と早期 return

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`
- Modify: `~/dotfiles/test/gfetchprune/run.fish`

**Interfaces:**
- Consumes: `__gfp_classify`。
- Produces: `__gfp_render <rows...>`(分類行を受けて整形表示)。`gfetchprune` が dry-run 時に classify→render を呼ぶ。

- [ ] **Step 1: 失敗するテストを追記(`rm -rf` の前)**

```fish
set -l out (gfetchprune 2>&1 | string collect)
gfp_assert "出力に削除予定見出し" "string match -q '*削除予定*' -- '$out'"
gfp_assert "出力に gone-only 要確認" "string match -q '*gone-unmerged*' -- '$out'"
gfp_assert "出力に保護(push無)" "string match -q '*local-merged*' -- '$out'"
gfp_assert "コピーファイル注意を表示" "string match -q '*.env.local*' -- '$out'"
```

- [ ] **Step 2: テスト実行で失敗を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: `FAIL`(render 未実装)。

- [ ] **Step 3: `__gfp_render` を実装し gfetchprune に dry-run 経路を組み込む**

`__gfp_render` を追加:

```fish
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
    __gfp_section "削除予定 worktree(merged+push済み)" delete-wt $rows
    __gfp_section "削除予定 branch(worktree なし)" delete-branch $rows
    __gfp_section "要確認: gone-only(リモート削除済み・未マージ固有コミットあり) [--include-gone-unmerged]" confirm-gone $rows
    __gfp_section "要確認: untracked のみ dirty [--include-untracked-dirty]" confirm-untracked $rows
    __gfp_section "保護(push 無の merged)" protect-nopush $rows
    __gfp_section "スキップ: 保護ブランチ" protect-branch $rows
    __gfp_section "スキップ: 保護パス" protect-path $rows
    __gfp_section "スキップ: dirty(作業中)" skip-dirty $rows
    __gfp_section "スキップ: カレント worktree" skip-current $rows
    __gfp_section "detached(手動確認推奨)" detached $rows
    __gfp_section "残す: 未マージ" keep-unmerged $rows
    echo "注意: worktree 削除時、git wt がコピーした .env.local 等の ignored ファイルも一緒に消えます。"
end
```

`gfetchprune` の末尾(Task 3 で挿入した fetch ブロックの後、`# 後続タスクで…` を置換)に:

```fish
    set -l rows (__gfp_classify $default $merge_target)

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

    # 実削除は次タスクで実装する
    __gfp_render $rows
    return 0
```

- [ ] **Step 4: テスト実行で通過を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`。

- [ ] **Step 5: Commit**

```bash
git add .config/fish/gfetchprune.fish test/gfetchprune/run.fish
git commit -m "feat(fish): dry-run の分類表示とコピーファイル注意を追加"
```

---

## Task 10: 実削除の安全実行

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`
- Modify: `~/dotfiles/test/gfetchprune/run.fish`

**Interfaces:**
- Consumes: classify の rows。
- Produces: `__gfp_execute <merge_target> <include_gone> <include_untracked> <rows...>`(安全削除)。`gfetchprune --execute` が呼ぶ。

- [ ] **Step 1: 失敗するテストを追記(`rm -rf` の前)。専用 fixture を使う**

```fish
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
popd >/dev/null
rm -rf (dirname "$ex")
```

- [ ] **Step 2: テスト実行で失敗を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 削除系 assertion が `FAIL`(execute 未実装で何も消えない)。

- [ ] **Step 3: `__gfp_execute` を実装し gfetchprune の execute 経路を差し替える**

`__gfp_execute` を追加:

```fish
function __gfp_execute --argument-names merge_target include_gone include_untracked
    set -l rows $argv[4..-1]
    set -l removed_branches

    # 1) worktree 削除(merged+push済み)。-f なし。失敗したらそのブランチは消さない
    for r in $rows
        set -l f (string split \t -- $r)
        set -l cat $f[1]; set -l br $f[2]; set -l path $f[3]
        set -l do 0
        test "$cat" = delete-wt; and set do 1
        test "$cat" = confirm-untracked -a "$include_untracked" = 1; and set do 1
        test "$cat" = confirm-gone -a "$include_gone" = 1; and set do 1
        test $do -eq 1; or continue

        if git worktree remove $path
            set -a removed_branches "$br\t$cat"
        else
            echo "skip(remove 失敗): $path"
        end
    end

    # 2) ブランチ削除。worktree なし削除候補 + worktree 削除済みのもの
    for r in $rows
        set -l f (string split \t -- $r)
        set -l cat $f[1]; set -l br $f[2]
        set -l do 0
        test "$cat" = delete-branch; and set do 1
        test $do -eq 1; or continue
        __gfp_delete_branch $br $merge_target 0
    end
    for rb in $removed_branches
        set -l p (string split \t -- $rb)
        set -l br $p[1]; set -l cat $p[2]
        set -l gone_flag 0
        test "$cat" = confirm-gone; and set gone_flag 1
        __gfp_delete_branch $br $merge_target $gone_flag
    end
end

# is-ancestor を削除直前に再確認してから -d→-D。gone-only(gone_flag=1)は -D 直行
function __gfp_delete_branch --argument-names branch merge_target gone_flag
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
```

`gfetchprune` の execute 経路(Task 9 の `# 実削除は次タスクで実装する` ブロック)を置換:

```fish
    __gfp_execute $merge_target $include_gone $include_untracked $rows
    return 0
```

- [ ] **Step 4: テスト実行で通過を確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`。

- [ ] **Step 5: Commit**

```bash
git add .config/fish/gfetchprune.fish test/gfetchprune/run.fish
git commit -m "feat(fish): 安全な実削除(remove -f 撤廃・-d→-D フォールバック・再検証)を追加"
```

---

## Task 11: 性能最適化(候補のみ merge-base/status)

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`

**Interfaces:**
- Consumes/Produces: 既存ヘルパの内部最適化のみ。外部 interface は不変。

**Note:** `__gfp_branch_meta` は Task 4 で既に 1 回の `for-each-ref` に集約済み。本タスクは `__gfp_emit_decision` がブランチ毎に `__gfp_branch_meta` を再走査している非効率を解消する(分類で 1 度取得したメタを引数で渡す)。`merge-base`/`status` は候補ブランチのみ呼ぶ(分類フローで既にそうなっている)ことを確認する。

- [ ] **Step 1: `__gfp_emit_decision` の再走査を除去(classify 本体でインライン lookup)**

`__gfp_emit_decision` のシグネチャを拡張し、冒頭でブランチメタを再取得していた `for m in (__gfp_branch_meta) … end` ループを削除する:

```fish
function __gfp_emit_decision --argument-names branch path merge_target kind up track
    set -l gone 0
    string match -q '*gone*' -- $track; and set gone 1
    # 以降(pushed/merged 判定と printf 群)は Task 8 の実装のまま変更しない
```

`__gfp_classify` の pass1/pass2 で `__gfp_emit_decision` を呼ぶ直前に、classify のローカル配列 `$meta_branch`/`$meta_up`/`$meta_track` から該当 branch の up/track をインラインで引いて渡す。**別関数にすると fish ではローカル配列が見えないため、必ず classify 本体に直接書く。**

pass1 の `__gfp_emit_decision $branch $path $merge_target wt` を次に置換:

```fish
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
```

pass2 の `__gfp_emit_decision $branch '-' $merge_target nowt` も、直前に同じ up/track 取得ブロックを置いてから次に置換:

```fish
        __gfp_emit_decision $branch '-' $merge_target nowt $up $track
```

- [ ] **Step 2: 既存テストで回帰がないことを確認**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`(分類・削除の結果は不変)。

- [ ] **Step 3: Commit**

```bash
git add .config/fish/gfetchprune.fish
git commit -m "perf(fish): 分類で取得済みのブランチメタを emit に渡し再走査を除去"
```

---

## Task 12: ドキュメント・ロード確認・本番 dry-run 受け入れ

**Files:**
- Modify: `~/dotfiles/.config/fish/gfetchprune.fish`(docstring/コメント)

**Interfaces:** なし(仕上げ)。

- [ ] **Step 1: ファイル冒頭に docstring コメントを追加**

`~/dotfiles/.config/fish/gfetchprune.fish` の先頭に:

```fish
# gfetchprune: カレント repo の push 済み・マージ済み worktree/branch を安全に掃除する。
# 対象: git wt 管理下(../.worktrees/{gitroot})と wkit(.git/.wkit-worktrees/)の両方。
# 既定 dry-run。実削除は --execute。
# 保護: gfp_protect_branches(+ PROTECT_BRANCHES 完全一致)/ gfp_protect_worktree_paths(+ PROTECT_WORKTREE_PATHS glob)。
# 設定例(local.fish): set -g PROTECT_BRANCHES my-keep-branch ; set -g PROTECT_WORKTREE_PATHS '*/sandbox'
```

- [ ] **Step 2: 関数定義と config.fish の source 行を確認**

Run: `fish -c 'source ~/dotfiles/.config/fish/gfetchprune.fish; functions -q gfetchprune; and echo ok'`
Expected: `ok`(ファイル単体で関数が定義される)。

Run: `grep -F 'source $HOME/dotfiles/.config/fish/gfetchprune.fish' ~/dotfiles/.config/fish/config.fish`
Expected: 1 行ヒット(Task 1 Step 4 で追加済み。symlink 済み config.fish が全シェル起動時に絶対パス source する)。

- [ ] **Step 3: 本物の castingone で dry-run 受け入れ確認(read-only)**

Run: `cd ~/dev/src/github.com/CastingONE/castingone; and gfetchprune`
Expected(目視):
- 「削除予定 worktree(merged+push済み)」に多数。
- 「スキップ: 保護ブランチ」に `stg`/`qa`。
- 「スキップ: 保護パス」に `.git/.wkit-worktrees/review`。
- 「保護(push 無の merged)」に upstream 無し merged。
- 「要確認: gone-only」に固有コミット数付き。
- 何も削除されていない(`git worktree list | wc -l` が実行前後で不変)。

- [ ] **Step 4: フルテスト実行**

Run: `fish ~/dotfiles/test/gfetchprune/run.fish`
Expected: 全 assertion `ok`、終了コード 0。

- [ ] **Step 5: Commit**

```bash
git add .config/fish/gfetchprune.fish
git commit -m "docs(fish): gfetchprune の docstring と設定例を追加"
```

---

## Self-Review(spec 対応確認)

- 既定 dry-run / `--execute` / 二重フラグ優先 → Task 1。
- gone 判定を track に修正 → Task 4。
- ブランチ保護(ハードコード + PROTECT_BRANCHES 正規化・空安全・メタ文字安全) → Task 5。
- パス保護(review 既定) → Task 6。
- dirty 分類(tracked 保護 / untracked 要確認) → Task 7,8,10。
- 述語(merged ∧ push済み ∧ clean ∧ 非保護)、gone-only 分離、push無 merged 保護 → Task 8。
- fetch fail-fast → Task 3。
- merge_target は origin 必須(ローカルフォールバック撤廃=spec より安全側) → Task 2。**spec からの逸脱を明記**。
- 削除の安全化(remove -f 撤廃 + 終了コード、-d→-D 再検証、順序固定) → Task 10。
- dry-run 分類表示・早期 return 限定・コピーファイル注意 → Task 9。
- 性能(一括 for-each-ref、候補のみ merge-base/status) → Task 4,11。
- detached 可視化 → Task 8,9。
- ドキュメント → Task 12。

**spec からの逸脱(意図的):**
1. `merge_target` のローカルフォールバックを撤廃し origin 必須にした(未 push マージ基準での誤削除を確実に防ぐため)。
2. 「コピー ignored ファイルがあればスキップ」は全件スキップに退化するため、per-worktree スキップではなく dry-run の総合注意表示に変更(Task 7 Note)。
3. `locked`/`prunable` の専用カテゴリ表示は今回見送り(現環境で 0 件、`remove` 失敗時は Task 10 が理由表示で継続するため安全性は担保)。将来 worktree が locked 運用になったら追加する。

**Placeholder scan:** なし。**Type consistency:** カテゴリ語彙とヘルパシグネチャは Task 8/10/11 間で一致。
