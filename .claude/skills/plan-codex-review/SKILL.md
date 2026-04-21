---
name: plan-codex-review
description: plan mode で作成したプランファイルを Codex にレビューさせ、設計漏れ・リスク・代替案・過剰設計を洗い出す。実装着手前のクロスチェックに使う。
argument-hint: [path/to/plan.md]
user-invocable: true
disable-model-invocation: true
context: fork
agent: general-purpose
allowed-tools: Read, Glob, Grep, Bash(codex *), Bash(ls *), Bash(mktemp *), Bash(cat *), Bash(wc *), Bash(pwd), Bash(dirname *), Bash(git ls-files *), Bash(git rev-parse *)
---

# Plan Codex Review

Claude Code の plan mode で作成したプランを、別系統の LLM である Codex に 3 ロール並列でレビューさせるスキル。実装着手前のクロスチェックに使う。

## Step 1: プランファイルの解決

`$ARGUMENTS` で渡されたパスを優先する。未指定の場合は以下の順で候補を探索する:

1. 現在の作業ディレクトリ直下の `PLAN.md` / `plan.md`
2. `.plans/` 配下の最も直近更新された `.md`
3. プロジェクトルート（`git rev-parse --show-toplevel`）配下の `PLAN.md`

候補が 0 件または複数あって一意に決まらない場合は、ユーザーに「どのファイルをレビューしますか？」と確認する。勝手に新規ファイルを作らない。

確定後、`wc -l` でサイズを把握し、2000 行を超える場合はユーザーに「長大ですが続行しますか？」と確認する。

## Step 2: プランと周辺コンテキストの特定

Codex にはパスを渡して Read させる方式を採るため、Claude 側はパスの特定が主な仕事。

1. **プランファイル**: `Read` で全文読む（Step 5 のマージ判断に必要）。パスは絶対パスで記録。
2. **参照ファイルの抽出**: プラン内に登場するファイルパス・ディレクトリパスを正規表現で抽出する。
3. **AGENTS.md / CLAUDE.md の探索**: 抽出したパスの親ディレクトリを辿り、存在する `AGENTS.md` と `CLAUDE.md` を両方リストアップする（リポジトリルートまで）。本文は読まない。
4. **参照コードファイル**: プラン内で明示的に「参照する」と書かれているファイルのパスをリストアップする。深追いしない。

成果物として以下 4 変数を用意する:

- `$PLAN_PATH`: レビュー対象プランの絶対パス
- `$AGENTS_MD_PATHS`: AGENTS.md の絶対パス配列
- `$CLAUDE_MD_PATHS`: CLAUDE.md の絶対パス配列
- `$REFERENCED_CODE_PATHS`: プランが参照する既存コードの絶対パス配列

## Step 3: 3ロール並列レビュー

独立した 3 つのロールで Codex を並列起動し、親プロセスを共有しないことでロール間の解釈バイアス伝播を防ぐ。

### 3.1 ロール定義

| ロール | 担当観点 |
| :-- | :-- |
| **A: 設計妥当性レビュアー** | 設計の正しさ / スコープ適正性（YAGNI・過剰抽象） / 既存アーキテクチャ整合性 / 実装順序・段階リリース可能性 |
| **B: 運用・セキュリティレビュアー** | authz / 入力検証 / 秘密情報の扱い / 可観測性（ログ・メトリクス） / 冪等性 / ロールバック / 失敗時挙動 |
| **C: 品質・テストレビュアー** | 未考慮のエッジケース / 境界値 / 並行性 / テスト戦略（正常・境界・異常・回帰） / 退行リスク |

各ロールは担当観点のみ深掘りし、範囲外は「スコープ外」として Suggestions に回す。

### 3.2 共通プロンプト本体

3 ロール共通の冒頭ブロック（可変部分はプロンプト末尾に置く）:

```
# 事前準備（必ず最初に実行）
以下のファイルを Read ツールで読み込んでからレビューを開始せよ。
レビュー指摘では行番号を可能な限り具体的に引用すること。

## レビュー対象プラン（必読）
- {$PLAN_PATH}

## プロジェクト規約（必読）
### AGENTS.md（Codex native、優先）
{AGENTS_MD_PATHS を箇条書きで列挙。存在しない場合は「なし」}

### CLAUDE.md（補足）
{CLAUDE_MD_PATHS を箇条書きで列挙。存在しない場合は「なし」}

## プランが参照している既存コード（必要に応じて読む）
{REFERENCED_CODE_PATHS を箇条書きで列挙。存在しない場合は「なし」}
深追いは避け、プランの妥当性判断に必要な範囲に留めること。
```

### 3.3 ロール別指示（共通プロンプトの末尾に追記）

```
# あなたのロール
あなたは {ロール名} に徹する Principal Software Engineer である。
担当観点: {担当観点一覧}

# 行動ルール
- **最初に「事前準備」セクションで指定されたファイルを Read ツールで読むこと**。読まずにレビューを始めてはならない
- 指摘には可能な限り「ファイル名:行番号」形式で該当箇所を引用する（例: `PLAN.md:L42`）
- 担当観点のみ深掘りする。他ロールの観点と重複する指摘は Suggestions に回してよい
- 指摘は「問題点 + 影響 + 実行可能な代替案」の形式で書く
- 確信のない指摘は Critical / Important に入れず、Suggestions に回す
- 褒める必要はない。一般論・nitpick は省く

# 出力フォーマット（必ずこの形式で返す）

## Verdict
[APPROVE / REVISE / REJECT] の 1 語 + 1 行理由

## Critical Issues
- 放置するとバグ・インシデント・手戻りに直結する指摘のみ。該当なしなら「なし」。

## Important Issues
- 実装前に解消しておくべき設計課題。nitpick は含めない。

## Suggestions
- 代替案や改善案。採用可否はユーザー判断。

## Missing Context
- プランだけでは判断できず、Claude / ユーザーに追加確認したい点。
```

### 3.4 並列実行

```bash
CWD="$(pwd)"
PLAN_DIR="$(dirname "$PLAN_PATH")"
ADD_DIR_ARGS=""
case "$PLAN_DIR" in
  "$CWD"*) ;;
  *) ADD_DIR_ARGS="--add-dir $PLAN_DIR" ;;
esac
# AGENTS.md / CLAUDE.md / 参照コードが cwd 外にあれば同様に ADD_DIR_ARGS へ追加

PROMPT_A=$(mktemp -t codex-plan-review-A-XXXX.md)
PROMPT_B=$(mktemp -t codex-plan-review-B-XXXX.md)
PROMPT_C=$(mktemp -t codex-plan-review-C-XXXX.md)
OUT_A=$(mktemp -t codex-plan-review-A-out-XXXX.md)
OUT_B=$(mktemp -t codex-plan-review-B-out-XXXX.md)
OUT_C=$(mktemp -t codex-plan-review-C-out-XXXX.md)

# 各 PROMPT_* に「共通プロンプト + ロール別末尾」を書き込む

codex exec --sandbox read-only --skip-git-repo-check --color never \
  -C "$CWD" $ADD_DIR_ARGS \
  --output-last-message "$OUT_A" - < "$PROMPT_A" &
PID_A=$!
codex exec --sandbox read-only --skip-git-repo-check --color never \
  -C "$CWD" $ADD_DIR_ARGS \
  --output-last-message "$OUT_B" - < "$PROMPT_B" &
PID_B=$!
codex exec --sandbox read-only --skip-git-repo-check --color never \
  -C "$CWD" $ADD_DIR_ARGS \
  --output-last-message "$OUT_C" - < "$PROMPT_C" &
PID_C=$!

wait $PID_A; STATUS_A=$?
wait $PID_B; STATUS_B=$?
wait $PID_C; STATUS_C=$?
```

- `--sandbox read-only`: ファイル変更禁止（Read は許可される）
- `-C "$CWD"`: Codex の作業ディレクトリと Read 許可範囲の基点
- `--add-dir`: プランファイル等が cwd 外にある場合の sandbox 許可追加
- `--output-last-message`: 最終回答のみを抜き出す
- `Bash` tool の `timeout` は 600000 (10分) を指定
- 部分失敗を許容。1 ロールが失敗しても残り 2 ロールでマージを進める。全ロール失敗時のみエラー終了
- `STATUS_*` がゼロでも出力に「ファイルを読めなかった」旨があるロールは failed 扱いとする

### 3.5 モデル指定

デフォルトモデルを使う。ユーザーが上位モデルを指定した場合は全ロールに `-m <model>` を追加する。

## Step 4: 結果のマージと信頼度判定

3 ロールの出力を `Read` で読み込み、以下のルールで統合する。

### 4.1 統合 Verdict

最も厳しいものを採用:

```
REJECT > REVISE > APPROVE
```

### 4.2 指摘の分類

各ロールの Critical / Important 指摘を突き合わせ、以下に分類する（意味ベースで判定。文言完全一致は不要）:

- **Consensus（信頼度高）**: 2 ロール以上で挙がっている指摘。実装前に必ず解消すべき
- **Role-specific（単独指摘）**: 1 ロールのみの指摘。担当観点の専門性を尊重する

### 4.3 失敗ロールの扱い

`STATUS_*` が非ゼロのロールがある場合、その事実を結果に明記する。失敗ロールの担当観点が Consensus 形成に効いていた可能性をユーザーに注意喚起する。全ロール失敗時はエラー終了。

## Step 5: 結果の提示

```markdown
## Codex Plan Review 結果（3ロール並列）

**対象プラン**: <解決したファイルパス>
**統合 Verdict**: <APPROVE / REVISE / REJECT>

| ロール | Verdict | 状態 |
| :-- | :-- | :-- |
| A: 設計妥当性 | <verdict> | <ok / failed> |
| B: 運用・セキュリティ | <verdict> | <ok / failed> |
| C: 品質・テスト | <verdict> | <ok / failed> |

### 🚨 Consensus（2ロール以上で指摘、信頼度高）
<Critical/Important 指摘を箇条書き。末尾に指摘元 [A,B] のようにロールを注記>

### ロール別単独指摘

#### A: 設計妥当性
<A の Critical/Important のうち Consensus に入らなかったもの>

#### B: 運用・セキュリティ
<B の Critical/Important のうち Consensus に入らなかったもの>

#### C: 品質・テスト
<C の Critical/Important のうち Consensus に入らなかったもの>

### Suggestions（全ロール合算）
<各ロールの Suggestions を重複排除して列挙>

### Missing Context（追加確認事項）
<各ロールの Missing Context を重複排除して列挙>

---

### 次アクション提案

1. プランを修正する（推奨度: ⭐⭐⭐〜⭐⭐⭐⭐⭐）
   - Consensus の指摘は最優先で反映
   - ロール別単独指摘は該当領域の重要度で判断
2. 指摘を却下して実装に進む
   - 却下する場合の根拠メモを残すことを推奨
3. Codex に追質問する
   - Missing Context に答える形で該当ロールのみ再レビュー可能
```

## Step 6: プラン修正への連携（任意）

ユーザーが「プランを修正して」と言った場合、Consensus とロール別単独指摘（Critical/Important のみ）をプランファイルへ直接反映する。反映前に差分をユーザーに提示し、承認を得てから `Edit` で書き込む。ユーザーの明示的な指示なしにプランファイルを書き換えない。

## 注意事項

- Codex の指摘を鵜呑みにせず、Claude 側の視点で妥当性を検討する。ロール間で矛盾する指摘がある場合は両論併記してユーザーに判断を委ねる。
- Codex が認証切れ等で失敗した場合は、`codex login` を促し、勝手にリトライしない。3 ロール同時に認証エラーが出た場合はセットアップ問題として即エラーで返す。
- このスキルはレビュー専用。実装や git 操作はしない。
