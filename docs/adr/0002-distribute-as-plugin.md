# 0002. プラグインとマーケットプレイスで配布し、名前は名前空間と重複させない

- Status: Accepted
- 日付: 2026-10-19
- 関連: docs/design/2026-10-initial-release.md

## Context（背景）
- sdd のスキルとサブエージェントは、これまで各自の `~/.claude/skills/` と `~/.claude/agents/` に手でコピーして使っていた。この方式では、更新しても利用者に行き渡らない。
- clone と導入スクリプト（シンボリックリンクを張る）で配る方法もある。ただし利用者に clone と bash の実行を求めることになり、公開物としては導入のハードルが高い。
- Claude Code のプラグインでは、スキルは `/<プラグイン名>:<スキル名>` で呼び出される。旧名のままプラグインにすると `/sdd:sdd-design` となり、`sdd` が重複して冗長になる。

## Decision（決定）
- Claude Code 純正のプラグインとマーケットプレイスの仕組みで配布すること。1 リポジトリを 1 マーケットプレイス（`sdd-lite`）とし、プラグインは `plugins/` の下に置くこと。
- スキル名とエージェント名から `sdd-` を外し、`/sdd:design`・`sdd:verifier` のように呼び出せる名前にすること。プラグインの名前と重複する接頭辞をスキル名に付けないこと。
- バージョンは semver で管理すること。リリースのたびに `plugin.json` の `version` を上げ、`vX.Y.Z` のタグを付けて CHANGELOG.md に記録すること。

## Consequences（結果）
- 呼び出し名が変わる。旧名で入れていた利用者は、旧スキルを削除してから導入し直す必要がある。
- 利用者は `/plugin` の画面や `claude plugin update` で更新を受け取れる。
- `version` を固定しているので、上げ忘れると更新が利用者に届かない。

## 検証方法（任意）
- `claude plugin validate --strict .` が警告なしで通ること。
- `grep -rnE 'sdd-(init|design|adr|ship|verifier)|ask-sdd|sdd-\*' plugins/ README.md CLAUDE.md` の結果が 0 件であること。
