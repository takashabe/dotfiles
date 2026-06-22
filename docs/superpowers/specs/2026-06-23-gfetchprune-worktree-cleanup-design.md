# gfetchprune 進化: worktree/branch 定期掃除コマンド 設計

- 日付: 2026-06-23
- 対象: `~/dotfiles/.config/fish/config.fish` の fish 関数 `gfetchprune`
- 種別: 既存関数の破壊的改修(振る舞い変更 + 安全化)

## 背景と根本原因

`git wt`(Homebrew `git-wt`)中心の運用で worktree が肥大化(castingone で登録238本、ローカルブランチ410本)。
原因は「掃除基準が狭い」だけではなく **実装バグ**:

- 現行の gone 判定は `%(upstream:trackshort)` を `*gone*` でマッチしているが、trackshort は記号(`< > = 空`)しか返さず **"gone" の語は決して現れない**。"gone" が出るのは長形式 `%(upstream:track)`(=`[gone]`)のみ。
- 結果、現行の「gone **かつ** merged」は gone 項が常に偽 → **検出 0 件**。これが肥大の真因。

実測(read-only): `is-ancestor`(merged)= 307、`track==[gone]` = 209、upstream 無し merged = 81、`gone かつ is-ancestor=false`(未マージ固有コミットあり)= 10。

## ゴール

カレント repo に対して、手動で安全に worktree とブランチを掃除するコマンド。
「何が・なぜ消え/残るか」を dry-run で可視化し、目視後に `--execute` で実削除する。

## 確定した設計判断

| 項目 | 決定 |
|---|---|
| 実装形態 | 既存 `gfetchprune` を進化(関数1つに保つ) |
| 既定動作 | **dry-run**。実削除は `--execute`/`-x` のみ。`-n`/`--dry-run` と同時指定時は dry-run 優先 |
| 対象範囲 | カレント repo のみ。手動コマンドのみ(launchd なし) |
| worktree スコープ | git wt 管理下(`../.worktrees/{gitroot}`)+ wkit(`.git/.wkit-worktrees/`)**両方**。`review` 枠はパス保護 |
| マージ済みの範囲 | **push 済み(upstream あり or gone)のみ**削除。upstream 無し merged(ローカル専用・空WIP 81件)は保護 |
| gone-only | 自動削除しない。表示のみ。`--include-gone-unmerged` 指定時のみ削除 |
| untracked のみ dirty | 保護(件数表示)。`--include-untracked-dirty` 指定時のみ削除 |
| `git worktree prune` | スコープ外。dry-run で prunable を表示し手動 prune を案内 |

## 削除述語(自動削除の条件)

ブランチ B(worktree W を持つ場合あり)について、**すべて**満たすとき自動削除候補:

1. `git merge-base --is-ancestor B origin/<default>` が真(= origin の default に取り込み済み。**唯一の安全シグナル**)
2. かつ **push 済み**: B が upstream を持つ、または gone(かつて upstream を持ちリモート削除済み)
3. かつ B が保護ブランチでない(後述)
4. かつ W(あれば)が保護パスでない、かつカレント worktree でない、かつ default ブランチでない
5. かつ W(あれば)が clean(後述の dirty 判定)

`gone かつ is-ancestor=false`(リモート削除済みだが default 未到達=固有コミットあり)は **データ消失リスク** のため自動削除に含めない。

## 保護モデル

### ① ブランチ保護(スコープ非依存・コードにハードコード既定 + 追加)
- ハードコード既定: `main master stg qa dev develop staging production prod release/*`
  - 実測で `stg`/`qa` は merged + upstream あり → 保護しないと削除される(critical)。
- `PROTECT_BRANCHES`(local.fish、未追跡)は**追加扱い**。正規化必須:
  - 空/未定義ならマッチ判定をスキップ(`^()$` への退化を防ぐ)。
  - リスト定義は `string join '|'` で alternation 化、または `contains` による完全一致照合。
  - 正規表現メタ文字の誤マッチ(`release/1.0` が `release/1x0` に当たる等)を防ぐため完全一致 or `string escape --style=regex`。

### ② worktree パス保護(scope=both で必要)
- `PROTECT_WORKTREE_PATHS`(local.fish + ハードコード既定)。既定に `review` スロットを含める。
  - `review`(`.git/.wkit-worktrees/review`): tmuxp/zellij が参照。順次 PR を checkout する枠 → 将来 merged 枝が載ると worktree ごと消える。
  - `ops/deploy`(branch=`stg`): ① のブランチ保護で自動的に守られる(追加不要)。
  - `chousa`(detached HEAD): branch 空で自動スキップ。

### ③ ファイル保護(スコープ非依存)
- git wt がコピーする gitignore 済みファイル(`.env*`, `compose.override.yaml`, `CLAUDE.local.md`)に手動編集がある worktree はスキップ + 警告。
  - `git status --porcelain` は ignored を出さないため、`--ignored=matching` でコピー対象パターンの存在を確認。
  - 削除すると唯一のコピー(シークレット/ローカル設定/手作業メモ)が復旧不能に消える。

## dirty 判定

- tracked 変更/staged あり → **保護**(作業中)。
- untracked のみ(生成物・メモ等) → **要確認**(既定保護、`--include-untracked-dirty` で削除可)。
- コピー対象 ignored ファイルに編集あり → スキップ + 警告。

## 検出・削除の堅牢化要件

- **fetch fail-fast**: `git fetch origin --prune` の終了コードを検査し、失敗時 `return 1`。dry-run でも失敗時は「判定が stale」を警告。
- **merge_target は origin/<default> 必須**: ローカル `refs/heads/<default>` フォールバックは「ローカルが origin より ahead でない」と確認できたときのみ。`origin/HEAD` が解決不能/stale なら `git remote set-head origin --auto` を案内して安全側に終了。`main`/`master` 決め打ちは `git show-ref --verify refs/remotes/origin/<name>` で実在確認してから採用。
- **gone 判定修正**: `%(upstream:track)` の `[gone]` で判定(`trackshort` は使わない)。
- **削除の安全化**:
  - worktree: `git worktree remove`(`-f` 撤廃)。終了コードを検査し、失敗した worktree のブランチは branch 削除候補から除外。
  - branch: merged 群は `git branch -d` を試行 → HEAD 基準で誤拒否されたら is-ancestor 再確認のうえ `git branch -D` にフォールバック。gone-only は `--include-gone-unmerged` 指定時のみ削除。
  - 削除直前に `is-ancestor` を再検証(TOCTOU 縮小)。順序は worktree 先 → branch 後(WHY コメントで固定)。
- **性能**: ブランチメタ(`refname:short`/`upstream:short`/`upstream:track`/`objectname`)を `for-each-ref` 1回で一括取得し fish で `string split`。`merge-base`/`status` は候補集合のみに実行(238 worktree + 410 branch で秒オーダー化を防ぐ)。

## dry-run 出力仕様

カテゴリ別に表示する:

- 削除予定 worktree/branch(merged + push済み + clean)
- 要確認: gone-only(固有コミット数 `git rev-list --count origin/<default>..B` 併記) / untracked-only dirty
- 保護(push 無): upstream 無し merged(81件相当)
- スキップ: dirty / protect(branch) / protect(path) / current / ignored-localfile / locked
- detached / prunable(可視化のみ)
- worktree 未使用ブランチ削除予定
- 残す未マージ件数

件数サマリに内訳(`merged:N / gone:M / no-upstream-merged:K`)を出す。
早期 return `already updated` は「削除候補0 かつ スキップ0 かつ未マージ残0」のときだけ。

## フラグ一覧

- `--execute` / `-x`: 実削除(既定は dry-run)
- `-n` / `--dry-run`: 明示 dry-run(`--execute` と同時なら dry-run 優先)
- `--include-gone-unmerged`: gone-only も削除対象に含める
- `--include-untracked-dirty`: untracked のみ dirty な worktree も削除対象に含める
- 未知引数は `case '*'` で Usage を返して終了

## スコープ外 / 別対応

- `work.yaml:30` / `work.kdl:53` が指す `local/review`(実在は `review`)のパスズレ修正 → 別 PR。
- `git worktree prune` の統合 → 現時点 prunable=0 のためスコープ外。dry-run 表示 + 手動案内に留める。
- ブランチ最終更新日による「直近 N 日は残す」閾値 → 将来の任意オプション。
- `--no-fetch`(dry-run の remote アクセス省略) → 将来の任意オプション。

## 実装ステップ順(レビュー統合)

0. **検証基盤**: 検出ロジックのみの dry-run 関数を先に作り、現行 predicate と新 predicate の検出件数を比較(`merged:307 / gone:209 / no-upstream-merged:81` を確認)。以降の回帰を件数で検証。
1. **安全側土台**: 既定 dry-run 反転 + `--execute`/`-x`、二重フラグ優先順位。削除ロジックは据え置き。
2. **fetch fail-fast**。
3. **default/merge_target 堅牢化**。
4. **gone 判定修正**(`track`=`[gone]`)。分類のみ、削除なし。
5. **保護の正規化**(PROTECT_BRANCHES 正規化 + ハードコード既定 + PROTECT_WORKTREE_PATHS)。
6. **条件緩和を分類付きで導入**(merged/push済み と gone-only を分離、upstream 無し merged を保護カテゴリ化)。
7. **dirty/ignored ガード**(候補のみ status 実行、tracked/untracked 分類、コピー ignored 検知、detached/locked/prunable 表示)。
8. **分類表示と早期 return 修正**。
9. **削除実行の安全化**(remove -f 撤廃 + 終了コード検査、-d→-D フォールバック、is-ancestor 再検証、順序固定)。
10. **性能最適化**(for-each-ref 一括取得、候補のみ merge-base/status)。
11. **ドキュメント/設定整合**(docstring に対象スコープと保護変数の期待形式・サンプル)。

## テスト観点

- 検出件数が新 predicate で想定通り(回帰検証)。
- `stg`/`qa` が保護される(削除候補に入らない)。
- 空/リスト/メタ文字を含む `PROTECT_BRANCHES` で保護が壊れない。
- gone-only(固有コミットあり)が既定で削除されない。
- `.env.local` のみ持つ worktree が clean 判定で消えない(`--ignored` 検知)。
- `review` パスが保護される。
- fetch 失敗時に削除へ進まない。
- 二重フラグ(`-x -n`)で dry-run になる。
