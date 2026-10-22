# 0010. 言語は純正の language 設定と CLAUDE.md の規約に任せる

- Status: Accepted
- 日付: 2026-10-22
- 関連: docs/design/2026-10-native-language.md、docs/adr/0006-i18n.md（これを置き換える）、docs/adr/0009-design-principles.md、docs/adr/0004-allow-reading-skill-files.md

## Context（背景）
- ADR 0006 で、出力言語を plugin.json の `userConfig.language`（`en` / `ja`）で選ぶようにした。しかし ADR 0006 の追記（docs/design/2026-10-i18n.md の T10）で、会話の言語は Claude Code 本体の `language` 設定がスキルの指示より優先されると分かった。プラグインの設定は、実質的に生成ファイルの言語とテンプレートの選択にしか効いていない。
- 本体の設定と重なる仕組みを自作で持つことは、ADR 0009 の原則 2（純正優先）に反する。ADR 0009 の Consequences に既知の違反として記録してある。
- 生成ファイルの言語は、プロジェクトの CLAUDE.md の規約で決められる。CLAUDE.md は毎回読まれ、チームで共有される。利用者ごとの `userConfig` よりも、チームで言語を揃える手段として適している。ADR 0006 も、揃えたいチームには CLAUDE.md の規約で決めるよう案内していた。
- スキルの補助ファイルの日本語訳（`.ja.md` 5 本）は、変更のたびに訳を直す手間を生み、判断基準の正本（guide）を 2 か所に分けていた。テンプレートの見出しはその場で訳せる。現在地の判定に使う記法（`- Status: ...`、`- [ ]`）は言語によらない。
- `userConfig` の `options` のために、Claude Code v2.1.271 以上を必須にしていた。

## Decision（決定）
- プラグインは言語の設定（`userConfig`）を持たないこと。スキルとエージェントは、会話の言語を指定しないこと。会話の言語は、本体の `language` 設定と Claude の既定の振る舞いに任せること。
- スキルが生成するファイル（CLAUDE.md・デザインドキュメント・ADR）とコミットメッセージ・PR の本文は、プロジェクトの CLAUDE.md（または AGENTS.md）の規約の言語で書くこと。規約が無ければ会話の言語で書くこと。
- テンプレートなどスキルの補助ファイルは、英語の 1 本だけを置くこと。言語ごとの補助ファイル（`.ja.md`）を置かないこと。生成するときは見出しを書く言語に訳してよいが、現在地の判定に使う記法（`- Status: Draft | Approved | Implemented`、`- [ ]` / `- [x]`）は訳さないこと。
- ADR 0006 の決定のうち、次を引き継ぐこと。
  - SKILL.md とエージェント定義（本文・description・argument-hint）は英語で書くこと。
  - 利用者向けの文書（README.md・CHANGELOG.md・guide.md・マニフェストの description）は英語を正本とすること。README には日本語訳 README.ja.md を置き、正本と同じ変更で更新し、先頭に相互のリンクを置くこと。
  - 開発用の文書（CLAUDE.md・docs/design/・docs/adr/）は日本語で書くこと。
  - `/sdd:ask` の判断基準の正本は `plugins/sdd/skills/ask/guide.md` の 1 か所に置くこと。
  - スキルは補助ファイルを `${CLAUDE_SKILL_DIR}` の下から Read ツールで読むこと。`..` を含むパスやシェル展開で、スキルのディレクトリの外を読まないこと。
  - README には guide の表や手順を重複させず、guide へのリンクだけを置くこと。
  - 各スキルの実行手順の正本はそれぞれの SKILL.md とし、guide には使い分けと流れを書くこと。

## Consequences（結果）
- ADR 0009 の既知の違反（userConfig の言語設定）が解消する。
- 訳を保守する対象が README.ja.md だけになる。guide の正本が再び 1 か所になる。
- 0.2.0 で `ja` を選んでいた利用者は、更新すると設定が効かなくなる。本体の `"language": "japanese"`（`/config` か settings.json）に移る必要がある。破壊的変更なので version を 0.3.0 に上げ、CHANGELOG と README に移行手順を書く。設定ファイルに残った `pluginConfigs` の値は使われない。
- v2.1.271 以上という必須の条件が無くなる。README には確認した版を書く。
- 本体の `language` 設定は自由記述で、プラグインから値を読めない。生成ファイルの言語は、規約が無いときは会話の言語に任せるしかなく、利用者によって混ざりうる。揃えたいプロジェクトは CLAUDE.md に規約を書く。`/sdd:init` の CLAUDE.md テンプレートに、その行を用意する。
- 見出しを訳した文書は、テンプレートと見出しの文言が一致しない。判定は見出しではなく記法で行っているので、ask の判定には影響しない。
- ADR 0006 の「プロジェクトの既存の文書の言語に合わせて、出力の言語を切り替えない」を引き継ぐ。規約が無いプロジェクトでは、既存の文書と新しい文書の言語が混ざりうる。揃える手段は CLAUDE.md の規約に一本化し、スキルが既存の文書の言語を調べる手間を増やさない。ただし `/sdd:init` が既存の CLAUDE.md に追記するときは、1 ファイルの中で言語が混ざらないよう、追記と言語の行を既存の CLAUDE.md の言語で書く。
- スキルのディレクトリの外を読まない決定は、純正の機能でスキルのディレクトリの外を安全に読めるようになったら見直す（ADR 0003 から引き継ぐ）。
- ADR 0006 は Superseded になる。

## 検証方法（任意）
- `grep -rnE 'user_config|\.ja\.md' plugins/` の結果が 0 件であること。
- `find plugins -name '*.ja.md'` の結果が 0 件であること。
- `grep -c userConfig plugins/sdd/.claude-plugin/plugin.json` の結果が 0 であること。
- `grep -n 'Status: Draft | Approved | Implemented' plugins/sdd/skills/design/template.md` の結果が 1 件であること。
- `` grep -rnE '\.\./|!`' plugins/ `` の結果が 0 件であること（ADR 0006 から引き継ぐ）。
