---
name: sdd-ship
description: 検証・ADR 確認・PR 作成
disable-model-invocation: false
metadata:
  kit: sdd
  reviewed: 2026-09-30
  retire-when: Claude Code 純正機能または同梱スキルが、検証・ADR 確認・コミット・PR 作成を一括で行えるようになったら削除する
---
1. sdd-verifier サブエージェントで、デザインドキュメントの要件と実装・テストを突き合わせる。アプリの動作確認が必要なら、同梱スキル /verify の利用も選べる。デザインドキュメントが無い変更では、関連する ADR と Plan Mode の計画ファイルを要件として渡す。
2. テスト・Lint・型チェックを実行し、失敗があれば修正する。
3. Claude Code の同梱スキル /simplify で変更差分を整理し、同じく同梱スキル /code-review で差分のバグを確認する。
4. 今回の変更で ADR にすべき判断が漏れていないか確認し、あれば /sdd-adr を提案する。
5. デザインドキュメントがあれば、タスクのチェックと Status を更新する。無い変更では、関連するドキュメント（README など）が更新されているかを確認する。
6. git 管理外のディレクトリでは、ここで終える（コミット・PR は行わない）。デフォルトブランチにいる場合は、コミットの前に作業ブランチを作る。変更内容を提示し、ユーザーの承認後にコミットと PR 作成を行う。コミットメッセージはプロジェクトの規約（CLAUDE.md や AGENTS.md）に従い、規約が無ければ Conventional Commits に従う。PR 作成には gh CLI を使い、PR 本文にデザインドキュメントと ADR へのリンクを含める。コミットと PR は必ずユーザーの承認を得てから行う。
