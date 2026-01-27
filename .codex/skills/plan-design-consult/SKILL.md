---
name: plan-design-consult
description: Create or refine implementation plan files while consulting on design policy. Use when a user wants a plan drafted, then wants to identify design decision points, evaluate options, and finalize decisions before handoff to another session.
---

# Plan Design Consult

## Overview

プランファイルを「大枠のたたき台」→「設計相談ポイントの抽出」→「個別方針の決定」→「実装セッションに渡せる完成形」へ整理する。

## Workflow (Plan → Consult → Decide → Finalize)

1. 目的とスコープを確認する
   - 目的、対象ファイル、参照元、スコープ外を明記する。

2. 大枠のプランを先に書き出す
   - 実装ステップを網羅的に列挙し、後で詰める前提で粗くてもよい。

3. 設計相談ポイントを洗い出す
   - 運用・並列度・冪等性・失敗時の扱い・引数・監視など、後からブレやすい項目を抽出する。
   - 相談対象の見出しを明確にして、後から差し替えやすくする。

4. 相談ポイントごとに選択肢を提示する
   - 選択肢は 1〜3 件に絞り、推奨度（⭐5段階）と理由を添える。
   - 可能なら「現状のコード/運用方針との整合性」を理由に含める。

5. 決定を反映してプランを更新する
   - 「決定: ...」として明記し、相談中の文言は消す。
   - スコープ外の項目（例: Cloud Scheduler）を明示する。

6. 完成レビューを行う
   - 1年スパン運用に耐えるか
   - 実装セッションに渡すのに必要十分か
   - 不足があれば最小限の追記だけ提案する

## Output Conventions

- 決定事項は「決定:」で統一する。
- 相談中の項目は「設計方針（決定済み）」に集約する。
- スコープ外は「前提」または専用の注記として明文化する。

## Example Requests (trigger hints)

- 「プランファイルを作りたい。設計方針は相談しながら決めたい」
- 「実装は別セッションでやるので、計画だけ必要十分に整えたい」
- 「選択肢の比較と推奨度を付けて決めたい」
