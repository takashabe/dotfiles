---
name: parallel-code-review
description: code-review plugin と codex review を並列実行し、結果をマージ表示するコードレビュースキル
user-invocable: true
---

# Parallel Code Review

Claude 多観点レビューと codex review を並列実行し、結果をマージ表示する。
Opus 4.7 / Codex 5.5 を想定した構成。

## 前提

ユーザーグローバル規約（`~/.claude/CLAUDE.md` → `@~/.codex/AGENTS.md`）は Claude / Codex 両者が自動で読み込む。Skill 側ではグローバル規約の配布を行わない。プロジェクトローカル `CLAUDE.md` / `AGENTS.md` の整合性はユーザー責任。

## Step 1: コンテキスト判定

Bash で以下を実行し、PRの有無を判定する:

```bash
gh pr view --json number,url,state,baseRefName,title,body 2>/dev/null
```

- 成功 → **PRモード**: PR の `baseRefName` を base branch として取得、`title`/`body` を意図情報として保持
- 失敗 → **uncommittedモード**: PR が存在しない

判定結果をユーザーに表示する:
- PRモード: `PR #<number> (<url>) を対象にレビューします`
- uncommittedモード: `PRが見つからないため、uncommitted changes を対象にレビューします`

## Step 2: コンテキスト一括収集

オーケストレータ側で以下を **すべて並列** に取得し、後続の全エージェントに同一データを配布する。各エージェントが個別にリポジトリを探索しないことで、トータルレイテンシとトークン使用量を抑える。

### 2a. 差分と変更ファイル一覧

**PRモード**:
```bash
gh pr diff
```

**uncommittedモード**:
```bash
git diff HEAD
git diff --cached
git status --short
```

差分から変更ファイル一覧を抽出する。

### 2b. プロジェクトローカル CLAUDE.md

Task エージェント（subagent_type=Explore）で以下を収集する:
- リポジトリルートの `CLAUDE.md`
- 変更ファイルが存在するディレクトリ階層の `CLAUDE.md`（親方向に辿る）
- それらが `@` でリンクするガイドラインファイル

ユーザーグローバル規約は対象外（Claude が起動時に既に読み込み済み）。

### 2c. 履歴コンテキスト

並列で以下を取得:
- `git log --oneline -n 20 -- <変更ファイル>`（変更ファイルごと）
- `git blame` で変更行近辺の最新コミット（重要箇所のみ、最大10ファイル）
- `gh pr list --search "<key file path>" --state merged --limit 10` で過去PRを検索

### 2d. 意図情報

**PRモード**: Step 1 で取得した `title` と `body`
**uncommittedモード**: `git log --format="%H%n%s%n%b%n---" -n 5` で直近コミットメッセージ

これは Step 3-A の Agent #4（設計意図 vs 実装）の入力になる。

### 2e. プリスクリーニング（任意）

差分が大きい場合（変更行数 > 500 または 変更ファイル数 > 10）、**Haiku 4.5** で初回スクリーニングし注目領域を抽出する:
- スクリーニングエージェントには差分のみを渡す
- `{file, range, reason}` のリストを返させる
- 後続エージェントはこのリストを優先度として参照する

差分が小さければこのステップはスキップする。

## Step 3: 並列レビュー実行

以下を **すべて並列** で実行する（単一メッセージ内で Task tool と Bash tool を同時呼び出し）。

各エージェントには Step 2 で収集したコンテキストをすべて渡す。エージェント側での追加探索は最小限にとどめる。

### 3-A. Claude 多観点レビュー

**PRモードの場合**: `code-review:code-review` plugin に一任する（Skill tool で呼び出し）。下記の4エージェント構成は使わない。

**uncommittedモードの場合**: 以下の4エージェントを Task tool で並列起動する。

各エージェントは以下のフォーマットで結果を返す:

```yaml
findings:
  - title: 簡潔な指摘タイトル
    file: path/to/file.go
    lines: "123-130"
    description: |
      何が問題か、影響、推奨対応
    confidence: 0-100  # スコアリング基準は後述
    reasoning: |
      スコアの根拠、反証検討の結果
```

#### Agent #1: 規約 / コメント準拠 (subagent_type=general-purpose)
- プロジェクトローカル `CLAUDE.md` および `@` リンク先ガイドラインへの準拠を監査
- 変更ファイル内のコードコメント（TODO, NOTE, FIXME, see:, 仕様コメント等）と変更内容の整合性をチェック
- CLAUDE.md はコード生成時のガイダンスであるため、レビュー時に該当しない指示（生成プロセスに関する指示など）は無視する

#### Agent #2: バグスキャン (subagent_type=feature-dev:code-reviewer)
- 変更差分から明らかなバグを検出
- 変更箇所以外の追加コンテキスト読み込みは最小限
- 重大なバグに集中し、些末な問題や nitpick は無視
- 偽陽性の可能性が高いものは confidence を下げる

#### Agent #3: 履歴コンテキスト (subagent_type=general-purpose)
- Step 2c で収集した `git blame` / `git log` / 過去PRコメントを参照
- 退行や過去議論の再現を検出
- 過去PRで指摘された内容が再発していないか確認

#### Agent #4: 設計意図 vs 実装 (subagent_type=general-purpose) **新規**
- Step 2d の意図情報（PR title/body または直近コミットメッセージ）と実装差分を突き合わせる
- 「やろうとしたこと」と「やったこと」の乖離、スコープクリープ、宣言された目的に対する未実装箇所を検出
- 意図情報が空 / 曖昧な場合は finding を生成せず、その旨を reasoning に記して空配列を返す

#### 3-A 共通: 自己批評ステップ

各エージェントには指摘リスト生成後に **自己批評** を必ず実施させる。プロンプトに以下を明記する:

> 各 finding について「この指摘が偽陽性である可能性は何か」を検討し、その結果を踏まえて confidence を確定せよ。検討内容は reasoning に含めること。

これにより、別エージェントによる独立スコアリング fan-out を不要にする。

### 3-B. Codex review

**PRモードの場合**:
```bash
codex review --base <baseRefName>
```

**uncommittedモードの場合**:
```bash
codex review --uncommitted
```

タイムアウト: 300秒。
ガイドラインは渡さない（codex 起動時に `~/.codex/AGENTS.md` および存在すればプロジェクト直下の `AGENTS.md` を自動読込済み）。

## スコアリング基準（3-A 各エージェントに渡す）

- **0**: 偽陽性。軽い精査で崩れる指摘、または既存の問題
- **25**: やや確信あり。実際の問題かもしれないが偽陽性の可能性もある。スタイル上の問題で CLAUDE.md に明示なし
- **50**: ある程度確信あり。実際の問題だが nitpick か発生頻度が低い
- **75**: 高い確信。ダブルチェック済みで実際に発生する可能性が高い。機能に直接影響するか CLAUDE.md に直接言及されている問題
- **100**: 絶対的確信。ダブルチェック済みで確実に問題、頻繁に発生する

偽陽性として confidence を下げるべき例:
- 既存の問題（変更前から存在）
- バグに見えるが実際にはバグでないもの
- シニアエンジニアが指摘しないような些末な nitpick
- linter / typechecker / コンパイラが検出する問題（import漏れ、型エラー、テスト破損、フォーマット）
- CLAUDE.md に明示されていない一般的なコード品質問題
- CLAUDE.md の指示だがコード内で明示的に抑制されているもの（lint ignore コメント等）
- 意図的な機能変更、またはより大きな変更に直接関連する変更
- ユーザーが変更していない行の問題

## Step 4: フィルタリングと結果マージ

3-A の各エージェントが返した finding のうち `confidence >= 80` のものだけ残す。

結果を以下の形式でユーザーに表示する:

```markdown
## Code Review Results

### Claude 多観点レビュー
<confidence >= 80 の finding 一覧。各 finding にスコア、観点（Agent名）、ファイル:行、根拠を付記>
<該当なしの場合は「重大な問題は検出されませんでした」>

### Codex
<codex 結果>

### Summary
- 共通して指摘された点（Claude / Codex 双方で類似指摘）
- Claude のみの指摘
- Codex のみの指摘
```

## 注意事項

- ビルドやテストの実行は行わない（CI で別途実行される前提）
- PRモードでは Claude 側は `code-review:code-review` plugin に一任し、4エージェント構成は使わない
- uncommittedモードでは plugin の代わりに4エージェント構成で同等以上のカバレッジを目指す
- ユーザーグローバル規約は Skill 側で配布せず、`CLAUDE.md ↔ AGENTS.md` の整合性に依存する
- 旧版にあった「指摘ごとに別エージェントを起動してスコアリングする fan-out」は廃止。各検出エージェントが自己批評を経て confidence を返す
