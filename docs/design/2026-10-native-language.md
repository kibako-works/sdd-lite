# 純正 language 設定への統合（ADR 0006 の置き換え）

- Status: Approved
- 作成日: 2026-10-22
- 関連 ADR: docs/adr/0006-i18n.md（Superseded にする）、docs/adr/0009-design-principles.md、docs/adr/0010-native-language.md（T1 で起票）

## 1. 背景と目的
- 0.2.0 で、出力言語を plugin.json の `userConfig.language`（`en` / `ja`）で選ぶようにした（ADR 0006）。しかし会話の言語は Claude Code 本体の `language` 設定が優先され（ADR 0006 の追記）、プラグインの設定は実質的に生成ファイルの言語とテンプレートの選択にしか効いていない。
- 本体の設定と重なる仕組みを自作で持っており、ADR 0009 の原則 2（純正優先）に反する。ADR 0009 の Consequences に既知の違反として記録してある。
- 言語ごとの補助ファイル（`.ja.md` 5 本）は、変更のたびに訳を直す手間を生み、guide を 2 か所に分けている。
- 成功の定義:
  - プラグインが言語の設定を持たず、会話の言語は本体の `language` 設定だけで決まる。
  - 生成文書の言語は、プロジェクトの CLAUDE.md の規約で決められる。規約が無ければ会話の言語になる。
  - スキルの補助ファイルは英語の 1 本だけになり、guide の正本は再び 1 か所になる。

## 2. スコープ
- やること:
  - plugin.json から `userConfig` を削除し、`version` を 0.3.0 に上げる。
  - 全スキル（ask・init・design・adr・ship）とエージェント（verifier）から、`${user_config.language}` による言語の分岐を削除し、生成文書の言語の決め方（CLAUDE.md の規約 → 会話の言語）を書く。
  - スキル用の `.ja.md`（guide.ja.md・design と adr の template.ja.md・init の claude-md-template.ja.md と adr-0001.ja.md）を削除する。
  - init の CLAUDE.md テンプレートに、生成文書の言語を決める 1 行を足す。
  - README.md・README.ja.md・CHANGELOG.md・CONTRIBUTING.md・PR テンプレート・バグ報告テンプレート・guide.md の、言語の設定と訳への言及を直す。
  - ADR 0010 を起票して ADR 0006 を Superseded にし、CLAUDE.md の ADR 0006 への参照を直す。
- やらないこと（Non-goals）:
  - README.ja.md の削除（残す。ユーザーの決定）。
  - 既存の利用者の設定ファイルに残った `pluginConfigs["sdd@sdd-lite"].options.language` の掃除。本体は使われない値を無視するので、README と CHANGELOG で消してよいと案内するだけにする。
  - スキルのフロントマター（description・argument-hint）の多言語化。
  - guide の判断基準の変更（次のデザイン「軽い方への反転と ship の段階化」で行う）。

## 3. 要件
- REQ-1: plugin.json に `userConfig` が無く、`version` が 0.3.0 であること。
- REQ-2: どのスキルとエージェントの本文にも `user_config` と `.ja.md` への言及が無く、会話の言語を指定する指示も無いこと（会話は本体の設定と既定の振る舞いに任せる）。
- REQ-3: init・design・adr が生成するファイル（CLAUDE.md・デザインドキュメント・ADR）は、プロジェクトの CLAUDE.md（または AGENTS.md）に文書の言語の規約があればそれに従い、無ければ会話の言語で書かれること。テンプレートの見出しはその言語に訳してよいが、現在地の判定に使う記法（`- Status: Draft | Approved | Implemented`、`- [ ]` / `- [x]`）は訳さないこと。
- REQ-4: ship は、コミットメッセージと PR の本文をプロジェクトの規約の言語で、無ければ会話の言語で書くこと。verifier は会話の言語で報告すること。
- REQ-5: `plugins/sdd/skills/` の下に `.ja.md` が無いこと。ask は英語の guide.md だけを読み、会話の言語で案内すること。
- REQ-6: init の CLAUDE.md テンプレートの「Coding conventions」に、生成文書の言語を決める行（`- Language of design docs and ADRs: <e.g. English>`）があること。
- REQ-7: README.md と README.ja.md が、次を案内していること。会話の言語は本体の `language` 設定（`/config` または settings.json の `"language"`）で決まること。生成文書の言語は CLAUDE.md の規約で決まり、無ければ会話の言語になること。0.2.0 で `ja` を使っていた利用者は本体の `"language": "japanese"` に移ること。前提の Claude Code の版は、必須の条件ではなく「v2.1.306 で確認」と書くこと。
- REQ-8: CHANGELOG.md の 0.3.0 に、破壊的変更として設定の削除と移行の手順が書かれていること。
- REQ-9: ADR 0010 が Accepted で、ADR 0006 の Status が `Superseded by 0010` であること。ADR 0006 の決定のうち、次は ADR 0010 で引き継ぐこと。利用者向けの文書は英語を正本にすること。README には日本語訳 README.ja.md を置き、同じ変更で更新すること。開発用の文書は日本語で書くこと。guide.md を判断基準の正本とすること。スキルのディレクトリの外を読まないこと。README に guide の表を重複させないこと。
- REQ-10: CLAUDE.md・CONTRIBUTING.md・PR テンプレートの、訳を置く対象が README だけになっていること。CLAUDE.md の参照先が ADR 0010 になっていること。バグ報告テンプレートの「Language setting」欄が無いこと。
- 非機能要件:
  - 予算: `bash .github/scripts/check-principles.sh` が 0 で終わること。変えたスキルとエージェントの `reviewed` を実施日に更新する。
  - セキュリティ: 既存の方針（ADR 0004）を保つ。`allowed-tools` は `Read(/${CLAUDE_SKILL_DIR}/*)` のまま。
  - 検証: `claude plugin validate --strict .` が警告なしで通り、`bash .github/scripts/check-public-files.sh` が 0 で終わること。

## 4. 設計
- 全体方針:
  - 会話の言語には触れない。本体の `language` 設定があればそれに、無ければ Claude の既定の振る舞い（利用者の言語に合わせる）に任せる。
  - 生成文書の言語は、各スキルの本文に 1 文で書く。英語の指示文の例: 「Write the generated file in the language that the project's CLAUDE.md (or AGENTS.md) specifies for documents; if it specifies none, use the language of the conversation. Translate the template's headings into that language, but keep `- Status: ...` values and `- [ ]` checkboxes as they are.」
  - テンプレートは英語の 1 本にする。見出しを訳した文書も、判定の記法が同じなので ask の判定（`grep '^- Status: Approved'`・`- [ ]`）はそのまま働く。
  - 本体の `language` 設定は自由記述（例: `"japanese"`）で、プラグインからは値を読めない。プラグインが値を読んで分岐する必要が無い設計にする。
- ファイル構成（変更後）:
  - `plugins/sdd/skills/ask/`: `SKILL.md`、`guide.md`
  - `plugins/sdd/skills/design/`・`adr/`: `SKILL.md`、`template.md`
  - `plugins/sdd/skills/init/`: `SKILL.md`、`claude-md-template.md`、`adr-0001.md`
  - `plugins/sdd/skills/ship/SKILL.md`、`plugins/sdd/agents/verifier.md`
- 移行（0.2.0 → 0.3.0）:
  - `ja` を使っていた利用者は、`/config` で本体の Language を設定するか、settings.json に `"language": "japanese"` を書く。日本語の文書を残したいプロジェクトは、CLAUDE.md に文書の言語の規約を書く。
  - `pluginConfigs` に残った値は使われない。消してもよい。
- 検討した代替案と不採用の理由（ADR 0010 に記録する）:
  - userConfig を残し、生成ファイルの言語だけを決める設定にする: 本体の設定と CLAUDE.md の規約で足り、原則 2 に反したままになる。利用者ごとの設定なので、チームで言語を揃える手段としても CLAUDE.md の規約に劣る。
  - `.ja.md` のテンプレートを残す: 訳の保守が続く。見出しはその場で訳せ、判定の記法は言語によらないので、不要である。
  - README.ja.md も削除する: 日本語の利用者が入口で読めなくなる。README は 1 本で保守の手間が小さいので残す（ユーザーの決定）。

## 5. 実装タスク
- [x] T1: `/sdd:adr` の手順で ADR 0010「言語は純正の language 設定と CLAUDE.md の規約に任せる」を起票し、ADR 0006 を `Superseded by 0010` にする。CLAUDE.md の「コーディング規約」の参照を直す（対応要件: REQ-9, REQ-10）
- [ ] T2: plugin.json から `userConfig` を削除し、`version` を 0.3.0 にする（REQ-1）
- [ ] T3: ask・ship・verifier の言語の段落を削除し、ship と verifier の文書と報告の言語の決め方を書く。guide.ja.md を削除し、guide.md の 3 行目を直す（REQ-2, REQ-4, REQ-5）
- [ ] T4: design・adr・init の言語の段落を、生成文書の言語の決め方に置き換え、`.ja.md` を削除する。init の CLAUDE.md テンプレートに言語の規約の行を足す（REQ-2, REQ-3, REQ-5, REQ-6）
- [ ] T5: README.md・README.ja.md・CHANGELOG.md・CONTRIBUTING.md・PR テンプレート・バグ報告テンプレートを直す（REQ-7, REQ-8, REQ-10）
- [ ] T6: 一時的な git リポジトリで、`--plugin-dir` と `claude -p` を使い、次の 3 通りで `/sdd:init` と `/sdd:adr` を実行し、生成ファイルの言語と判定の記法を確かめる。①本体の `language` が `japanese`・規約なし ②本体の設定なし・英語で依頼・規約なし ③本体の `language` が `japanese`・CLAUDE.md に英語の規約あり（REQ-3, REQ-6）

## 6. テスト・検証方法
- 共通（タスクごと）: `claude plugin validate --strict .`、`bash .github/scripts/check-principles.sh`、`bash .github/scripts/check-public-files.sh` が通ること。
- REQ-1: `grep -c userConfig plugins/sdd/.claude-plugin/plugin.json` が 0、`"version": "0.3.0"` があること。
- REQ-2・REQ-5: `grep -rnE 'user_config|\.ja\.md' plugins/` が 0 件、`find plugins -name '*.ja.md'` が 0 件であること。
- REQ-3・REQ-6: T6 で、①は日本語、②は英語、③は英語で生成され、どれも `- Status:` の値と `- [ ]` が訳されていないこと。
- REQ-4: ship と verifier の本文を読んで確かめる（E2E は行わない）。
- REQ-7・REQ-8・REQ-10: 該当のファイルを読み、`grep -rn '2\.1\.271\|guide\.ja\|0006' README* CONTRIBUTING.md CLAUDE.md .github/` の結果が意図どおり（0006 は Superseded の経緯の説明だけ）であること。
- REQ-9: ADR 0006 と 0010 の Status を確かめる。`` grep -rnE '\.\./|!`' plugins/ `` が 0 件であること。

## 7. 未決事項
- なし。
