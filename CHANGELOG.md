# 変更履歴

このプロジェクトの変更点を記録します。バージョンは [セマンティック バージョニング](https://semver.org/lang/ja/) に従います。

## [0.1.0] - 2026-10-19

### 追加
- マーケットプレイス `sdd-lite` とプラグイン `sdd` として初めて公開。
- スキル `/sdd:ask`・`/sdd:init`・`/sdd:design`・`/sdd:adr`・`/sdd:ship` と、サブエージェント `sdd:verifier`。

### 変更
- 各自の `~/.claude/skills/` に置いて使っていた版から、スキル名とエージェント名を変更（`ask-sdd` → `ask`、`sdd-init` → `init`、`sdd-design` → `design`、`sdd-adr` → `adr`、`sdd-ship` → `ship`、`sdd-verifier` → `verifier`）。旧名で導入していた場合は、旧スキルを削除してから導入し直してください。
