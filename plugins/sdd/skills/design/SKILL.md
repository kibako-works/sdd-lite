---
name: design
description: 新機能・中規模以上の変更のデザインドキュメントを作成する（Plan Mode で実行）
argument-hint: <機能名や概要>
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)
metadata:
  kit: sdd
  reviewed: 2026-09-30
  retire-when: Claude Code 純正の Plan Mode がデザインドキュメント形式の計画をリポジトリ内 Markdown として保存・承認できるようになったら削除する
---
対象: $ARGUMENTS

このスキルは Plan Mode で実行する。

0. docs/design/ や docs/adr/ が無ければ、/sdd:init を案内する。
1. CLAUDE.md、関連コード、docs/adr/ の Accepted な ADR を読む。
2. 要件・スコープ・制約について、不明点を1問ずつ質問する（推測で埋めない）。
3. ${CLAUDE_SKILL_DIR}/template.md に沿って計画をまとめ、承認を求める。
4. 承認後、docs/design/YYYY-MM-<slug>.md として保存し、Status を Approved にする。
5. 代替案の比較など重要な判断があれば /sdd:adr の起票を提案する。
実装コードはこのスキルでは書かないこと。
