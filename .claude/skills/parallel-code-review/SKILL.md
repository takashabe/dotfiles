---
name: parallel-code-review
description: code-review plugin と codex review を並列実行し、結果をマージ表示するコードレビュースキル
user-invocable: true
---

# Parallel Code Review

Claude 多観点レビューと codex review を並列実行し、結果をマージ表示する。

## Step 1: コンテキスト判定

Bash で以下を実行し、PRの有無を判定する:

```bash
gh pr view --json number,url,state,baseRefName 2>/dev/null
```

- 成功 → **PRモード**: PRが存在する。`baseRefName` をbase branchとして取得する
- 失敗 → **uncommittedモード**: PRが存在しない

判定結果をユーザーに表示する:
- PRモード: `PR #<number> (<url>) を対象にレビューします`
- uncommittedモード: `PRが見つからないため、uncommitted changes を対象にレビューします`

## Step 2: 差分とCLAUDE.mdの取得

### 2a. 差分の取得

**PRモードの場合**:
```bash
gh pr diff
```

**uncommittedモードの場合**:
```bash
# staged + unstaged + untracked の全変更を取得
git diff HEAD
git diff --cached
git status --short
```
変更のあるファイル一覧を特定する。

### 2b. CLAUDE.mdの収集

Task エージェント（subagent_type=Explore）で以下を収集する:
- リポジトリルートの `CLAUDE.md`
- 変更ファイルが存在するディレクトリ階層の `CLAUDE.md`（親ディレクトリも含む）
- CLAUDE.md内で `@` リンクされているガイドラインファイルの内容

## Step 3: 並列レビュー実行

以下を **すべて並列** で実行する（単一メッセージ内で Task tool と Bash tool を同時呼び出し）:

### 3-A. Claude 多観点レビュー（5つの Task エージェントを並列実行）

各エージェントには差分・変更ファイル一覧・CLAUDE.mdの内容を渡す。
各エージェントは指摘一覧と、各指摘の根拠（CLAUDE.md準拠、バグ、git履歴コンテキスト等）を返す。

**PRモードの場合**: code-review plugin（Skill tool で `code-review:code-review`）を代わりに実行する。
この場合は 5つの Task エージェントは起動せず、plugin に一任する。

**uncommittedモードの場合**: 以下の5つのエージェントを Task tool で並列起動する。

1. **Agent #1: CLAUDE.md 準拠チェック** (subagent_type=general-purpose)
   - CLAUDE.md およびリンク先ガイドラインの指示に対して、変更が準拠しているかを監査する
   - CLAUDE.md はコード生成時のガイダンスであるため、レビュー時に該当しない指示は無視する

2. **Agent #2: バグスキャン** (subagent_type=feature-dev:code-reviewer)
   - 変更差分を読み、明らかなバグを浅くスキャンする
   - 変更箇所以外の追加コンテキスト読み込みは最小限にとどめる
   - 重大なバグに集中し、些末な問題やnitpickは無視する
   - 偽陽性の可能性が高いものは無視する

3. **Agent #3: git履歴コンテキスト** (subagent_type=general-purpose)
   - 変更対象ファイルの `git blame` と `git log` を確認する
   - 過去の変更履歴を踏まえたバグや退行がないかを特定する

4. **Agent #4: 過去PRコメント** (subagent_type=general-purpose)
   - 変更対象ファイルに触れた過去のPRを `gh pr list --search` で検索する
   - それらのPRコメントで、今回の変更にも該当する指摘がないか確認する

5. **Agent #5: コードコメント準拠** (subagent_type=general-purpose)
   - 変更対象ファイル内のコードコメント（TODO, NOTE, FIXME, see:, 仕様コメント等）を確認する
   - 変更内容がそれらのコメントの指示に準拠しているか確認する

### 3-B. Codex review

**PRモードの場合**:
```bash
codex review --base <baseRefName>
```

**uncommittedモードの場合**:
```bash
codex review --uncommitted
```

タイムアウト: 300秒

## Step 4: 信頼度スコアリング

Step 3-A の各エージェントから返された指摘について、エージェントを **指摘ごとに並列起動** し、信頼度スコア（0-100）を付ける。

各エージェントには以下を渡す:
- 対象の差分
- 指摘内容
- 関連する CLAUDE.md ファイル一覧

スコアリング基準（エージェントにそのまま渡す）:
- **0**: 偽陽性。軽い精査で崩れる指摘、または既存の問題。
- **25**: やや確信あり。実際の問題かもしれないが、偽陽性の可能性もある。スタイル上の問題の場合、CLAUDE.md に明示されていない。
- **50**: ある程度確信あり。実際の問題だが、nitpick か実際にはあまり起きない。PR全体の中で重要度が低い。
- **75**: 高い確信。ダブルチェック済みで、実際に発生する可能性が高い。PRの既存アプローチでは不十分。コードの機能に直接影響するか、CLAUDE.md に直接言及されている問題。
- **100**: 絶対的確信。ダブルチェック済みで、確実に問題であり、頻繁に発生する。

偽陽性の例（スコアリング時に考慮する）:
- 既存の問題（変更前から存在）
- バグに見えるが実際にはバグでないもの
- シニアエンジニアが指摘しないような些末なnitpick
- linter/typechecker/コンパイラが検出する問題（import漏れ、型エラー、テスト破損、フォーマット）
- CLAUDE.md に明示されていない一般的なコード品質問題
- CLAUDE.md の指示だがコード内で明示的に抑制されているもの（lint ignore コメント等）
- 意図的な機能変更、またはより大きな変更に直接関連する変更
- ユーザーが変更していない行の問題

## Step 5: フィルタリングと結果マージ

スコア **80以上** の指摘のみ残す。

結果を以下の形式でユーザーに表示する:

```markdown
## Code Review Results

### Claude 多観点レビュー
<スコア80以上の指摘一覧。各指摘にスコア、観点（Agent#）、根拠を付記>
<該当なしの場合は「重大な問題は検出されませんでした」>

### Codex
<codex結果>

### Summary
- 共通して指摘された点
- Claude のみの指摘
- Codex のみの指摘
```

## 注意事項
- codex review にはプロジェクトのガイドラインを渡さない（デフォルトレビューのみ）
- PRモードでは Claude 側は code-review plugin に一任し、5エージェント構成は使わない
- uncommittedモードでは code-review plugin の代わりに5エージェント構成で同等のレビューを行う
- ビルドやテストの実行は行わない（CIで別途実行される前提）
