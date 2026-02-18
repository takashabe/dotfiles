---
name: commit-push-pr
description: uncommittedな変更をconventional commit形式で意味のある小さい粒度でコミットし、pushしてPRテンプレートに沿ったPRを作成する。「コミットしてPR作って」「commit push PR」「変更をまとめてPR出して」などのリクエストで発動する。PRが既に存在する場合はコミットとpushを行い、descriptionと実装に乖離があれば追記形式で更新する。
---

# Commit, Push & PR

uncommittedな変更を分析し、conventional commit形式でコミット→push→PR作成を一括で行う。

## ワークフロー

### Step 1: 状態確認

以下を並列で実行:

```bash
git status                          # uncommittedファイル一覧
git diff --stat                     # 変更ファイルの統計
git diff                            # 詳細差分
git log --oneline -10               # 最近のコミットスタイル確認
cat .github/PULL_REQUEST_TEMPLATE.md # PRテンプレート取得
```

新規ファイルがある場合は内容も確認する。

### Step 2: 除外ファイルの判定

以下のファイルはコミット対象外:
- `.serena/` 配下の設定ファイル
- プランファイル（`*.md` で明らかにプラン用途のもの）
- ユーザーから明示的に除外指示があったファイル

判断に迷う場合はユーザーに確認する。

### Step 3: コミット粒度の決定

変更を論理的なまとまりで分類する。分類基準:
- **レイヤー**: domain / usecase / infrastructure / interface 等、DDDのレイヤー構造に従う
- **機能**: 共通ロジック / 個別適用 / テスト
- **依存関係**: シグネチャ変更とそれを呼ぶ側は同一コミットにして各コミットのビルド可能性を維持

典型的な分割パターン:
1. 共通ロジック・ユニットテスト
2. 機能統合・配線・統合テスト

### Step 4: Conventional Commitでコミット

形式: `<type>(<scope>): <説明>`

- type: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
- scope: サービス名（`tenant`, `messenger`）またはモジュール名（`delivery`, `job`）など、変更の主要ドメインを指定
- 説明は日本語で記述
- 本文は変更の「なぜ」を1-2行で記述

```bash
git add <specific-files>
git commit -m "$(cat <<'EOF'
feat(delivery): SMS配信のバリデーションロジックを追加

配信本文中のURL数を制限するバリデーションを実装。
EOF
)"
```

ファイルは `git add` で個別指定する（`git add .` や `git add -A` は使わない）。

### Step 5: Push

```bash
git push -u origin <branch-name>
```

リモートブランチが既にある場合は `-u` なしで `git push`。

### Step 6: PR作成（PRが存在しない場合のみ）

まずPRの存在確認:
```bash
gh pr view --json number 2>/dev/null
```

PRが存在しなければ作成。

**ベースブランチの決定（MUST）:**
1. `gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/branches --jq '.[] | select(.protected) | .name'` でprotected branchの一覧を取得する
2. AskUserQuestionToolで選択肢として提示し、ユーザーに選択させる（featブランチ等はOtherで手動入力）
3. `--base` フラグは必ず指定する。省略は禁止

PR bodyはリポジトリのテンプレートに従う:
1. Step 1で取得した `.github/PULL_REQUEST_TEMPLATE.md` の構造を使用
2. テンプレート内のコメント行（`<!-- -->`）は除去し、各セクションに変更内容に応じた記述を埋める
3. テンプレートが存在しない場合は、変更の要約をシンプルに記述する

```bash
gh pr create --base <ユーザーが選択したブランチ> --title "<conventional commitと同形式>" --body "$(cat <<'EOF'
<テンプレートのセクション構造に従って記述>
EOF
)"
```

PRが既に存在する場合は、pushに加えてdescriptionの追記更新を行う:

1. `gh pr view --json body,baseRefName` で現在のdescriptionとベースブランチを取得
2. `git diff <baseRefName>...HEAD` で現在の全体差分を確認し、今回pushした変更内容を把握
3. 現在のdescriptionが実装内容をカバーしているか判断
4. 乖離がある場合、既存のdescriptionは**一切変更せず**、末尾に追記する:
   - 当日の `## 追記（YYYY-MM-DD）` セクションが既に存在する場合は、そのセクション内に箇条書きを追加する
   - 存在しない場合は新規セクションを作成する

```markdown
## 追記（YYYY-MM-DD）

- <変更内容の箇条書き>
```

5. `gh pr edit --body` で更新

```bash
gh pr edit <pr-number> --body "$(cat <<'EOF'
<既存のbody全文（当日セクションがあればそこに追記済み）>
EOF
)"
```

6. 乖離がない場合は追記不要。PR URLのみ表示する。

### Step 7: 結果報告

コミット一覧とPR URLをテーブル形式で表示する。
