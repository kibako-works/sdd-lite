---
name: init
description: 今のプロジェクトに軽量SDD（CLAUDE.md・docs/design/・docs/adr/）を導入する
argument-hint: [プロジェクトルート（省略時はカレント）]
disable-model-invocation: true
metadata:
  kit: sdd
  reviewed: 2026-09-30
  retire-when: Claude Code 純正の /init などがデザインドキュメント・ADR 用ディレクトリと開発フローの雛形まで生成するようになったら削除する
---
対象: $ARGUMENTS

1. 対象プロジェクトのルートを決める（引数があればそれ、無ければ git root かカレント）。
2. CLAUDE.md が無ければ、${CLAUDE_SKILL_DIR}/claude-md-template.md を元に、リポジトリを調べて分かる箇所（技術スタック・コマンド・主要ディレクトリ）を埋めた案を作る。既にある場合は上書きせず、「開発フロー」「設計上の決定事項」の節で不足している分だけを追記する差分案を作る。
3. docs/design/ と docs/adr/ を作り、docs/adr/0001-record-architecture-decisions.md を ${CLAUDE_SKILL_DIR}/adr-0001.md から今日の日付で作る案を作る。既に docs/adr/ があればスキップして報告する。
4. すべての案を提示し、ユーザーの承認を得てから書き込む。コミットはしない。
