# プロジェクト概要
- 目的：軽量 SDD（デザインドキュメントと ADR）を Claude Code で回すプラグイン `sdd` を、公開マーケットプレイス `sdd-lite` として配布する
- 技術スタック：Markdown（Claude Code のスキル・サブエージェント）、JSON（プラグインのマニフェスト）
- 主要ディレクトリ：plugins/sdd/（skills/・agents/・.claude-plugin/）/ .claude-plugin/ … マーケットプレイス定義 / docs/ … デザインドキュメントと ADR

# よく使うコマンド
- 検証：`claude plugin validate --strict .`
- ローカルで試す：`claude --plugin-dir ./plugins/sdd`

# 開発フロー（必ず守る）
1. 新機能・中規模以上の変更は、実装前に docs/design/ にデザインドキュメントを作る（/sdd:design）。
2. デザインドキュメントは人間の承認を得てから実装に入る。
3. 小さな修正（1ファイル程度・設計判断なし）は Plan Mode で計画を示すだけでよい。
4. 実装はデザインドキュメントの「実装タスク」を上から1つずつ進め、タスクごとにテストを通す。
5. 技術選定・構造変更・トレードオフのある判断をしたら docs/adr/ に ADR を起票する（/sdd:adr）。
6. 完了時は /sdd:ship で検証・ADR 確認・PR 作成を行う。

初回は、承認済みの docs/design/2026-10-initial-release.md の実装タスクを上から進める。
この時点ではプラグインがまだ導入されていないため、/sdd:* が使えない間は、各スキルの SKILL.md の手順を読んで同じことを行う。

# 設計上の決定事項
- 過去の判断は docs/adr/ を参照すること。Status が Accepted の ADR に反する実装をしない。
- ADR と矛盾する変更が必要なら、実装前に新しい ADR で既存 ADR を Superseded にする提案をする。

# コーディング規約
- 利用者向けの文書（README.md・CHANGELOG.md・SKILL.md・エージェント定義・スキルの補助ファイル・マニフェストの description）は英語を正本にする。README とスキルの補助ファイルには日本語訳（`<名前>.ja.md`）を置き、訳は正本と同じ変更で更新する（ADR 0006）。
- 開発用の文書（CLAUDE.md・docs/design/・docs/adr/）とコミットメッセージは日本語で書く。
- コミットは Conventional Commits（`<型>(<スコープ>): <件名>`、件名は日本語）。スコープはスキル名（ask・init・design・adr・ship・verifier）、全体は `repo`。
- リリースのたびに plugin.json の `version` を semver で上げ、CHANGELOG.md に追記して `vX.Y.Z` のタグを付ける。
- Mermaid のノードラベル内の改行は `<br/>` を使う（`\n` は使わない）。

# やってはいけないこと
- 作者の勤務先や業務に関する情報、メールアドレス、個人環境の絶対パスを書かない。
- スキルから `..` を含むパスやシェル展開で、スキルのディレクトリの外を読ませない。
- push・タグ付け・リポジトリの公開設定の変更は、人間の確認なしに行わない。
