# sdd-lite 初回リリース（プラグイン化と公開）

- Status: Approved
- 作成日: 2026-10-19
- 関連 ADR: docs/adr/0001〜0004（0001〜0003 は T4、0004 は T6 で起票）

## 1. 背景と目的
- sdd は、軽量な SDD（デザインドキュメントと ADR で開発を進める方法）を Claude Code で回すためのスキル 5 つとサブエージェント 1 つ。
  - スキル: `ask-sdd`・`sdd-init`・`sdd-design`・`sdd-adr`・`sdd-ship`
  - サブエージェント: `sdd-verifier`
- これまでは各自の `~/.claude/skills/` と `~/.claude/agents/` に置いて使っていた。これを Claude Code のプラグインとして公開リポジトリから配れるようにする。
- 方針は「Claude Code 純正の機能を可能な限りそのまま使い、自作は足りない部分だけの最小限にする」。純正の機能に同じものが入ったら、そのスキルは外す（期限付きの運用）。
- 成功の定義:
  - GitHub の公開リポジトリ `<owner>/sdd-lite` から、`/plugin marketplace add <owner>/sdd-lite` と `/plugin install sdd@sdd-lite` で導入できる。
  - 導入後、`/sdd:ask`・`/sdd:init`・`/sdd:design`・`/sdd:adr`・`/sdd:ship` が、改名前と同じように動く。

## 2. スコープ
- やること:
  - このリポジトリを、マーケットプレイス `sdd-lite` とプラグイン `sdd` の構成にする。
  - スキル名とエージェント名を、名前空間と重複しない形に変える（4 章の対応表）。
  - スキル本文・guide.md・テンプレートの中の名前の参照を、新しい名前に揃える。
  - README・CHANGELOG・LICENSE（MIT）・ADR 0001〜0003 を書く。
  - GitHub に公開し、v0.1.0 のタグを付ける。
- やらないこと（Non-goals）:
  - 英語化（日本語のみで公開する）。
  - スキルの中身（手順・判断基準）の変更。名前と配布方法以外は変えない。
  - Anthropic の公式ディレクトリへの申請。

## 3. 要件
- REQ-1: `claude plugin validate --strict .` が警告なしで通ること。
- REQ-2: `/plugin marketplace add <owner>/sdd-lite` と `/plugin install sdd@sdd-lite` で導入できること。導入後、5 つのスキルとエージェント `sdd:verifier` が使えること。
- REQ-3: `/sdd:design` と `/sdd:init` は、これまでどおり人間だけが起動できること（`disable-model-invocation: true` を維持する）。
- REQ-4: 配布物に旧名（`ask-sdd`・`sdd-init`・`sdd-design`・`sdd-adr`・`sdd-ship`・`sdd-verifier`・`/sdd-*`）が残っていないこと。`/sdd:init` が導入先に書き込む CLAUDE.md のテンプレートも対象にする。
- REQ-5: 公開物に、作者の勤務先や業務に関する情報、メールアドレス、`/home/<個人名>` のような個人環境のパスが含まれないこと。git の履歴も対象にする。作者の表記は GitHub のユーザー名だけにする。
- REQ-6: スキルが `${CLAUDE_SKILL_DIR}` 経由で、自分のディレクトリにある guide.md とテンプレートを読めること。
- 非機能要件:
  - バージョンは semver で管理する。リリースのたびに `plugin.json` の `version` を上げ、`vX.Y.Z` のタグを付けて CHANGELOG.md に記録する。`version` を固定すると、上げない限り更新が利用者に届かないため。
  - 公開物は日本語のみで書く。

## 4. 設計

### 全体方針
1 リポジトリを 1 マーケットプレイスとし、その中に `plugins/sdd` を置く。今後ほかのプラグインを公開するときは `plugins/` に足す。

### 構成
```
sdd-lite/
├── .claude-plugin/marketplace.json
├── plugins/sdd/
│   ├── .claude-plugin/plugin.json
│   ├── skills/{ask,init,design,adr,ship}/
│   └── agents/verifier.md
├── docs/adr/
├── docs/design/
├── CLAUDE.md
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
```

### 名前の対応表
| 旧名 | 新しいディレクトリ・ファイル | 呼び出し名 |
|---|---|---|
| `ask-sdd` | `skills/ask/` | `/sdd:ask` |
| `sdd-init` | `skills/init/` | `/sdd:init` |
| `sdd-design` | `skills/design/` | `/sdd:design` |
| `sdd-adr` | `skills/adr/` | `/sdd:adr` |
| `sdd-ship` | `skills/ship/` | `/sdd:ship` |
| `sdd-verifier` | `agents/verifier.md` | `sdd:verifier` |

- 各 SKILL.md とエージェントの、フロントマターの `name:` も新しい名前にする。プラグインではフロントマターの `name` がスキル名として優先されるため。
- 次のフロントマターはそのまま残す。
  - `description`（中の旧名は直す）
  - `argument-hint`
  - `disable-model-invocation`
  - `metadata`（`kit`・`reviewed`・`retire-when`）
  - エージェントの `tools`
- 自分のディレクトリのファイルを読むスキル（`ask`・`adr`・`design`・`init`）には、`allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)` を追加する（ADR 0004。T6 で、無いと読むたびに許可を求められることが分かったため）。

### 書き換える箇所
- 旧名は `grep -rnE 'sdd-(init|design|adr|ship|verifier)|ask-sdd|sdd-\*' plugins/` ですべて見つかる。主な箇所は次のとおり。
  - `skills/ask/guide.md`: 全体の流れの図（mermaid。改行は `<br/>` を使う）、手順、コマンド一覧の表、現在地の判定の表、依頼文の例
  - `skills/ask/SKILL.md`: description の「sdd-* スキル」「/ask-sdd 〇〇したい」
  - `skills/init/claude-md-template.md`: 開発フローの `/sdd-design`・`/sdd-adr`・`/sdd-ship`
  - `skills/ship/SKILL.md`: 「sdd-verifier サブエージェント」→「sdd:verifier サブエージェント」と `/sdd-adr`
  - `skills/design/SKILL.md`・`skills/adr/SKILL.md`: `/sdd-init`・`/sdd-adr`
- 「sdd-* スキル」のような総称は「sdd プラグインのスキル」と書き換える。

### マニフェスト
- marketplace.json: 必須は `name`・`owner`（`owner.name` が必須）・`plugins`。各エントリは `name` と `source` が必須で、`description` は無いと validate が警告を出す。
  ```json
  {
    "name": "sdd-lite",
    "owner": { "name": "<GitHub ユーザー名>", "url": "https://github.com/<GitHub ユーザー名>" },
    "description": "軽量 SDD（デザインドキュメントと ADR）を Claude Code で回すプラグイン",
    "plugins": [
      { "name": "sdd", "source": "./plugins/sdd", "description": "軽量 SDD のスキル群と検証用サブエージェント" }
    ]
  }
  ```
- plugin.json: 必須は `name` だけ。ただし `version`・`description`・`author` が無いと validate が警告を出す。
  ```json
  {
    "name": "sdd",
    "version": "0.1.0",
    "description": "軽量 SDD のスキル群と検証用サブエージェント",
    "author": { "name": "<GitHub ユーザー名>", "url": "https://github.com/<GitHub ユーザー名>" },
    "repository": "https://github.com/<GitHub ユーザー名>/sdd-lite",
    "license": "MIT"
  }
  ```
- marketplace.json の `plugins[].name` と plugin.json の `name` は揃える。インストールにはエントリ名を使い、スキル名の接頭辞には plugin.json の名前を使うため。
- 上の例のフィールド名は公式ドキュメントを要約して得たもの。T5 の validate で最終確認する。

### README の章立て
- 構成: 概要 → 前提 → インストール → 使い方 → 注意点 → 外す条件 → 外す手順 → 詳しく
- 概要: 何をするプラグインか。ほかの SDD ツールより軽い代替として作ったこと。ほかのプロジェクトを評価する書き方はしない。
- 前提: Claude Code が動く環境。完了時の手順で、Claude Code 同梱の `/simplify`・`/code-review`（必要なら `/verify`）を使う。PR 作成には gh CLI を使う。
- インストール: `/plugin marketplace add <owner>/sdd-lite` → `/plugin install sdd@sdd-lite`。更新と削除の方法（`/plugin` の画面、または `claude plugin update` / `uninstall`）。
- 使い方: 迷ったら `/sdd:ask <やりたいこと>` を使う。判断基準の正本は `plugins/sdd/skills/ask/guide.md` なので、そこへリンクし、guide.md の表や手順は README に重複させない（ADR 0003）。
- 注意点:
  - 人間だけが起動できるスキルがある（`/sdd:design`・`/sdd:init`）。
  - `/sdd:init` は承認前に何も書き込まず、コミットもしない。
  - `/sdd:ship` のコミットと PR は、必ず承認を得てから行う。コミットメッセージはプロジェクトの規約に従い、規約が無ければ Conventional Commits に従う。
- 外す条件: 各スキル・エージェントの `metadata.retire-when` を表にする（対象・外す条件の 2 列）。
- 外す手順:
  1. 純正の機能が入ったことを確認する。
  2. 該当のスキルを削除し、README の表、guide.md の手順とコマンド一覧、テンプレートを直す。`ask` を外すときは、guide.md の内容を README などへ戻す。
  3. `version` を上げてリリースする。
  4. 利用者は、プラグインを更新すれば反映される。

### ADR（T4 で起票。テンプレートは `plugins/sdd/skills/adr/template.md`）
- 0001: ADR で判断を記録する。`plugins/sdd/skills/init/adr-0001.md` をそのまま使ってよい。
- 0002: プラグインとマーケットプレイスで配布し、名前は名前空間と重複させない。
  - 背景: `~/.claude/skills/` に手でコピーする方式では、更新が行き渡らない。clone と導入スクリプトを要求すると、公開物としては導入のハードルが高い。
  - 決定:
    - 純正のプラグインとマーケットプレイスで配る。
    - スキル名からは `sdd-` を外し、`/sdd:design` などにする。`/sdd:sdd-design` は冗長なため。
    - バージョンは semver で管理する。
  - 結果:
    - 呼び出し名が変わる。旧名で入れていた利用者は、旧スキルを消して入れ直す必要がある。
    - 更新は `/plugin` から行える。
- 0003: 案内の判断基準の正本を `skills/ask/guide.md` に置き、スキルのディレクトリの外は読まない。過去の検証で分かった次の事実を、背景として必ず書く。
  - `${CLAUDE_SKILL_DIR}` には、シンボリックリンクを解決しないパスが入る。`${CLAUDE_SKILL_DIR}/../../README.md` を Read ツールで読むと、Read は `..` をリンクをたどらずに畳むので失敗する。
  - SKILL.md のシェル展開（`` !`cat ...` ``）で外部のファイルを読むと、作業ディレクトリの外を読むことになり、既定の権限で止まる。利用者ごとに許可の設定が要る。
  - 決定:
    - `ask` は `${CLAUDE_SKILL_DIR}/guide.md` を Read で読む。`..` を含むパスやシェル展開は使わない。
    - README には人間向けの内容（背景・前提・導入・外す条件と手順・注意点）とリンクだけを置き、guide.md と重複させない。
    - 各スキルの実行手順の正本はそれぞれの SKILL.md とし、guide.md には使い分けと流れを書く。
  - 結果:
    - 判断基準が 1 か所になる。
    - `ask` を外すときは、guide.md の内容を移す必要がある。
    - 純正の機能で、スキルのディレクトリの外を安全に読めるようになったら見直す。

### 検討した代替案と不採用理由
- 導入スクリプトとシンボリックリンクで配る案: 呼び出し名は変わらないが、利用者に clone と bash を求めるため不採用。
- `/sdd:sdd-design` のように旧名のままプラグインにする案: `sdd` が重複して冗長なため不採用。

## 5. 実装タスク
- [ ] T1: `git init` し、LICENSE（MIT。著作者は GitHub のユーザー名）、`.claude-plugin/marketplace.json`、`plugins/sdd/.claude-plugin/plugin.json`、CHANGELOG.md（0.1.0 の項目）、`.gitignore` を置く。（対応要件: REQ-1）
- [ ] T2: 4 章の対応表に従って、スキルのディレクトリとエージェントのファイルを `git mv` で改名し、フロントマターの `name` と本文・guide.md・テンプレートの旧名を書き換える。（REQ-2, REQ-3, REQ-4, REQ-6）
- [ ] T3: README.md を 4 章の章立てで書く。（REQ-2, REQ-5）
- [ ] T4: docs/adr/0001〜0003 を起票する。（REQ-5）
- [ ] T5: 6 章の grep と `claude plugin validate --strict .` で確認する。（REQ-1, REQ-4, REQ-5）
- [ ] T6: ローカルで動作を確認する。`claude --plugin-dir ./plugins/sdd` で起動するか、`claude plugin marketplace add ./` と `claude plugin install sdd@sdd-lite` で導入して、6 章の REQ-2・REQ-3・REQ-6 を確かめる。
  - `/sdd:ship` から検証役を呼ぶときの指定名（`subagent_type`）が `sdd:verifier` で通るかは公式ドキュメントに明記がないので、ここで実際に確かめる。通らなければ SKILL.md の書き方を直す。（REQ-2, REQ-3, REQ-6）
- [ ] T7: GitHub にプライベートリポジトリ `sdd-lite` を作って push し、`v0.1.0` のタグを付ける。外部への送信なので、実行前に必ず人間の確認を取る。（REQ-2, REQ-5）
- [ ] T8: ローカルのマーケットプレイスを外し（`claude plugin marketplace remove sdd-lite`）、GitHub（プライベートリポジトリ）から導入し直して、T6 と同じ確認をする。プラグインがキャッシュのディレクトリから読まれる状態でも、ADR 0004 の `allowed-tools` で補助ファイルを確認なしに読めることを確かめる。（REQ-2）
- [ ] T9: 公開してよいかを確かめてから、リポジトリを public に切り替える。（REQ-2, REQ-5）
  - `/security-review` で脆弱性を確認する。
  - 6 章の REQ-5 の確認を、履歴（`git log -p --all`）まで含めてやり直す。勤務先や業務を示す語が無いことを、人間が読んで確認する。
  - 履歴を書き換える必要があれば、ここで行う（force push とタグの付け直しを含む）。
  - 切り替え（`gh repo edit --visibility public`）は、実行前に必ず人間の確認を取る。
  - 切り替えたあと、ローカルのマーケットプレイスを外して GitHub から入れ直し、`/plugin` の一覧に `sdd@sdd-lite` が出ることを確かめる。

## 6. テスト・検証方法
- REQ-1: `claude plugin validate --strict .` が警告なしで終わる。
- REQ-2:
  - `/plugin` の一覧に `sdd@sdd-lite` が出る。
  - `/sdd:ask デザインドキュメントを書きたい` を実行すると、`/sdd:design` が案内される。
  - 一時的な git リポジトリで `/sdd:ship` の手順 1 を実行すると、`sdd:verifier` が起動する。
- REQ-3: Claude に「デザインドキュメントを作って」と頼んでも `/sdd:design` を自分で起動せず、人間に入力を案内する。
- REQ-4: `grep -rnE 'sdd-(init|design|adr|ship|verifier)|ask-sdd|sdd-\*' plugins/ README.md CLAUDE.md` の結果が 0 件になる。
- REQ-5:
  - `grep -rnE '@[A-Za-z0-9.-]+\.[a-z]{2,}|/home/[a-z]' --exclude-dir=.git .` の結果が 0 件になる。
  - 作者の勤務先や業務を示す語が無いことを、人間が README と ADR を読んで確認する。
  - `git log --format='%an <%ae>'` に、GitHub が発行する noreply アドレス（ユーザー ID とユーザー名から成る、users.noreply.github.com のアドレス）以外が出ない。push 前に `git config user.email` を確認する。
- REQ-6:
  - `/sdd:adr テスト` で ADR の雛形が出る（一時ディレクトリで実行し、書き込みは承認しない）。
  - `/sdd:init` で CLAUDE.md の案が `/sdd:*` の名前で出る。

## 7. 未決事項
- なし。`<owner>`（GitHub のユーザー名）は、実装時に人間に確認して埋める。
