# sdd-lite

[English](README.md) | 日本語

軽量な SDD（デザインドキュメントと ADR で開発を進める方法）を Claude Code で回すためのプラグイン `sdd` を配布するマーケットプレイスです。

## 概要

`sdd` は、次のスキル 5 つとサブエージェント 1 つからなるプラグインです。

| 名前 | 役割 |
|---|---|
| `/sdd:ask` | どのスキルを使うか迷ったときの窓口。今の状態と変更の規模から、次の手順を案内する |
| `/sdd:init` | プロジェクトに CLAUDE.md・`docs/design/`・`docs/adr/` を導入する |
| `/sdd:design` | 新機能・中規模以上の変更について、Plan Mode の計画にデザインドキュメントの書式を与え、承認後に `docs/design/` に保存する |
| `/sdd:adr` | ADR（判断記録）を起票する |
| `/sdd:ship` | 完了時の検証・ADR の確認・コミットと PR 作成を、変更の規模に合わせてまとめて行う |
| `sdd:verifier` | デザインドキュメントの要件と実装・テストを突き合わせるサブエージェント |

仕様駆動開発のためのツールはほかにもありますが、それらより軽く始められる代替として作りました。Claude Code 純正の機能（Plan Mode・`/simplify`・`/code-review` など）をできるだけそのまま使い、足りない部分だけをスキルにしています。純正の機能に同じものが入ったら、そのスキルは外します（[外す条件](#外す条件)）。

## 前提

- Claude Code v2.1.306 で動作を確認しています。
- 完了時の手順で、Claude Code 同梱のスキル `/simplify`・`/code-review`（アプリの動作確認が必要なら `/verify`）を使います。
- `/sdd:ship` で PR を作るときは [GitHub CLI（gh）](https://cli.github.com/) を使います。

## インストール

Claude Code の中で、次の 2 つを実行します。

```
/plugin marketplace add kibako-works/sdd-lite
/plugin install sdd@sdd-lite
```

更新と削除は、`/plugin` の画面から行えます。ターミナルからは次のコマンドでも行えます。

```bash
# 更新（マーケットプレイスの情報を取り直してから、プラグインを更新する）
claude plugin marketplace update sdd-lite
claude plugin update sdd@sdd-lite

# 削除
claude plugin uninstall sdd@sdd-lite
claude plugin marketplace remove sdd-lite
```

## 言語

sdd は、言語の設定を持ちません。

- 会話は Claude Code 本体の `language` 設定に従います。`/config` で設定するか、settings.json に `"language": "japanese"` などを書きます。設定が無ければ、Claude は書き込んだ言語で答えます。
- スキルが生成するファイル（CLAUDE.md・デザインドキュメント・ADR）と、`/sdd:ship` のコミットメッセージ・PR の本文は、プロジェクトの CLAUDE.md（または AGENTS.md）で決めた文書の言語に従います。決めていなければ、会話の言語で書きます。`/sdd:init` は、そのための行を CLAUDE.md に入れます。
- テンプレートは英語です。ほかの言語で書くときは見出しを訳しますが、`- Status:` の行と `- [ ]` のチェックボックスは英語のままにします。スキルが現在地の判定に使うためです。
- 0.2.0 で `ja` を選んでいた場合、その設定はもう効きません。代わりに Claude Code の `language` を `japanese` にし、プロジェクトの文書を日本語にしたい場合は CLAUDE.md にそう書いてください。ユーザー設定の `pluginConfigs["sdd@sdd-lite"].options.language` は消してかまいません。

## 使い方

迷ったら、やりたいことを添えて `/sdd:ask` を実行してください。今の状態と変更の規模から、次に入力するコマンドと手順を案内します。

```
/sdd:ask デザインドキュメントを書きたい
```

全体の流れ、変更の規模の判定、各スキルの使い分けは [plugins/sdd/skills/ask/guide.md](plugins/sdd/skills/ask/guide.md) にまとめています。判断基準はこのファイルが正本です（[ADR 0010](docs/adr/0010-native-language.md)）。英語で書いてあります。

## 注意点

- `/sdd:design` と `/sdd:init` は、人間だけが起動できます。Claude からは起動できないので、Claude が案内したら人間が入力してください。
- `/sdd:design` は Plan Mode で実行します。質問と計画の承認は Plan Mode が行います。計画の最初のタスク T0 が、計画を Status: Approved にして `docs/design/YYYY-MM-<slug>.md` に保存するので、承認のときに context を消しても保存されます。`plansDirectory` を設定する必要はありません。
- `/sdd:init` は、案を示して承認を得るまで何も書き込みません。コミットもしません。
- Claude が自分で `/sdd:ask`・`/sdd:adr` を呼ぶときは、スキルの実行に承認を求められます。スキルが自分のファイル（guide.md やテンプレート）を読む権限を持っているためです。確認を省きたい場合は、権限の設定（`/permissions`）で `Skill(sdd:ask)`・`Skill(sdd:adr)` を許可してください。
- `/sdd:ship` のコミットと PR 作成は、必ず承認を得てから行います。コミットメッセージはプロジェクトの規約（CLAUDE.md や AGENTS.md）に従い、規約が無ければ Conventional Commits に従います。
- `/sdd:ship` は、最初に変更の区分を 1 行で宣言し、小さな変更に要らない手順を省きます。区分は、承認済みのデザインドキュメントがあれば A、ブランチで ADR を追加していれば B、どちらも無ければ C です。差分が実行時の設定・公開 API・依存関係・セキュリティや、CLAUDE.md に書いた場所などに触れていれば上がります（条件の一覧は ship の `SKILL.md` にあります）。変えたいときは `/sdd:ship A`（または `B`・`C`）と実行します。詳しくは [guide](plugins/sdd/skills/ask/guide.md) を見てください。

## 外す条件

各スキルとエージェントは、Claude Code 純正の機能で代わりが利くようになったら外します。条件は各ファイルのフロントマター `metadata.retire-when` に書いてあり、次の表はその日本語訳です。

| 対象 | 外す条件 |
|---|---|
| `/sdd:ask` | Claude Code 純正の機能が、スキル群の中から使うものを案内・振り分けるようになったら、または sdd の他のスキルがすべて外れたら |
| `/sdd:init` | Claude Code 純正の /init などが、デザインドキュメント・ADR 用ディレクトリと開発フローの雛形まで生成するようになったら |
| `/sdd:design` | Claude Code 純正の Plan Mode が、承認した計画を、決めたファイル名でリポジトリに保存し、承認済みの印を付けられるようになったら |
| `/sdd:adr` | Claude Code 純正の機能として、ADR（判断記録）の起票・連番管理が提供されたら |
| `/sdd:ship` | Claude Code 純正の機能または同梱スキルが、検証・ADR 確認・コミット・PR 作成を一括で行えるようになったら |
| `sdd:verifier` | Claude Code 純正または同梱のエージェント・スキルが、デザインドキュメントの要件と実装・テストの突き合わせ検証を行えるようになったら |

## 外す手順

1. 純正の機能が入ったことを確認する。
2. 該当のスキルを削除し、README（英語版と日本語版）の表、guide.md の手順とコマンド一覧、テンプレートを直す。`ask` を外すときは、guide の内容を README などへ戻す。
3. `plugin.json` の `version` を上げてリリースする。
4. 利用者は、プラグインを更新すれば反映される。

## 詳しく

- 判断基準と使い分け: [plugins/sdd/skills/ask/guide.md](plugins/sdd/skills/ask/guide.md)（英語）
- 設計上の判断: [docs/adr/](docs/adr/)
- 変更履歴: [CHANGELOG.md](CHANGELOG.md)
- コントリビュートの方法: [CONTRIBUTING.md](CONTRIBUTING.md)（英語）
- 脆弱性の報告: [SECURITY.md](SECURITY.md)（英語）

## ライセンス

[MIT](LICENSE)
