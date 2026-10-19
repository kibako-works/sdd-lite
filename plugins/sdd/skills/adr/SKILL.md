---
name: adr
description: ADR を起票する
argument-hint: <判断のタイトル>
disable-model-invocation: false
metadata:
  kit: sdd
  reviewed: 2026-09-30
  retire-when: Claude Code 純正機能として ADR（判断記録）の起票・連番管理が提供されたら削除する
---
対象: $ARGUMENTS

0. docs/adr/ が無ければ、/sdd:init を案内する。
1. docs/adr/ の最大番号 +1 で連番を決める。
2. ${CLAUDE_SKILL_DIR}/template.md に沿って、会話と関連デザインドキュメントから Context / Decision / Consequences を下書きする。
3. 既存 ADR と矛盾する場合は Superseded にすべき ADR を示す。
4. 下書きを提示し、承認後に docs/adr/NNNN-<slug>.md として保存する。
