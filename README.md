# sdd-lite

軽量な SDD（デザインドキュメントと ADR で開発を進める方法）を Claude Code で回すためのプラグイン `sdd` を配布するマーケットプレイスです。

## 概要

`sdd` は、次のスキル 5 つとサブエージェント 1 つからなるプラグインです。

| 名前 | 役割 |
|---|---|
| `/sdd:ask` | どのスキルを使うか迷ったときの窓口。今の状態と変更の規模から、次の手順を案内する |
| `/sdd:init` | プロジェクトに CLAUDE.md・`docs/design/`・`docs/adr/` を導入する |
| `/sdd:design` | 新機能・中規模以上の変更のデザインドキュメントを作る |
| `/sdd:adr` | ADR（判断記録）を起票する |
| `/sdd:ship` | 完了時の検証・ADR の確認・コミットと PR 作成をまとめて行う |
| `sdd:verifier` | デザインドキュメントの要件と実装・テストを突き合わせるサブエージェント |

仕様駆動開発のためのツールはほかにもありますが、それらより軽く始められる代替として作りました。Claude Code 純正の機能（Plan Mode・`/simplify`・`/code-review` など）をできるだけそのまま使い、足りない部分だけをスキルにしています。純正の機能に同じものが入ったら、そのスキルは外します（[外す条件](#外す条件)）。

## 前提

- Claude Code が動く環境。
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

## 使い方

迷ったら、やりたいことを添えて `/sdd:ask` を実行してください。今の状態と変更の規模から、次に入力するコマンドと手順を案内します。

```
/sdd:ask デザインドキュメントを書きたい
```

全体の流れ、変更の規模の判定、各スキルの使い分けは [plugins/sdd/skills/ask/guide.md](plugins/sdd/skills/ask/guide.md) にまとめています。判断基準はこのファイルが正本です（[ADR 0003](docs/adr/0003-guide-as-single-source.md)）。

## 注意点

- `/sdd:design` と `/sdd:init` は、人間だけが起動できます。Claude からは起動できないので、Claude が案内したら人間が入力してください。
- `/sdd:init` は、案を示して承認を得るまで何も書き込みません。コミットもしません。
- `/sdd:ship` のコミットと PR 作成は、必ず承認を得てから行います。コミットメッセージはプロジェクトの規約（CLAUDE.md や AGENTS.md）に従い、規約が無ければ Conventional Commits に従います。

## 外す条件

各スキルとエージェントは、Claude Code 純正の機能で代わりが利くようになったら外します。条件は各ファイルのフロントマター `metadata.retire-when` に書いてあり、次の表はその写しです。

| 対象 | 外す条件 |
|---|---|
| `/sdd:ask` | Claude Code 純正の機能が、スキル群の中から使うものを案内・振り分けるようになったら、または sdd の他のスキルがすべて外れたら |
| `/sdd:init` | Claude Code 純正の /init などが、デザインドキュメント・ADR 用ディレクトリと開発フローの雛形まで生成するようになったら |
| `/sdd:design` | Claude Code 純正の Plan Mode が、デザインドキュメント形式の計画をリポジトリ内の Markdown として保存・承認できるようになったら |
| `/sdd:adr` | Claude Code 純正の機能として、ADR（判断記録）の起票・連番管理が提供されたら |
| `/sdd:ship` | Claude Code 純正の機能または同梱スキルが、検証・ADR 確認・コミット・PR 作成を一括で行えるようになったら |
| `sdd:verifier` | Claude Code 純正または同梱のエージェント・スキルが、デザインドキュメントの要件と実装・テストの突き合わせ検証を行えるようになったら |

## 外す手順

1. 純正の機能が入ったことを確認する。
2. 該当のスキルを削除し、この README の表、guide.md の手順とコマンド一覧、テンプレートを直す。`ask` を外すときは、guide.md の内容を README などへ戻す。
3. `plugin.json` の `version` を上げてリリースする。
4. 利用者は、プラグインを更新すれば反映される。

## 詳しく

- 判断基準と使い分け: [plugins/sdd/skills/ask/guide.md](plugins/sdd/skills/ask/guide.md)
- 設計上の判断: [docs/adr/](docs/adr/)
- 変更履歴: [CHANGELOG.md](CHANGELOG.md)

## ライセンス

[MIT](LICENSE)
