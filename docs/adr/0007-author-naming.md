# 0007. 作者名を入れないのは公開物の名前と表記に限り、コミットや GitHub 上の操作者は個人アカウントでもよい

- Status: Accepted
- 日付: 2026-10-22
- 関連: docs/design/2026-10-contribution-readiness.md、docs/adr/0005-owner-is-organization.md（これを置き換える）

## Context（背景）
- ADR 0005 では、公開物と履歴から作者の個人名が分からないように、コミットの作者とコミッターを `kibako-works` の noreply アドレスに限っていた。
- main に PR を必須にする Ruleset を入れた。GitHub の画面で PR をマージすると、merge・squash・rebase のどの方法でも、作者かコミッターに個人アカウントが入る。実際に `5de880b`（PR #1 のマージ）の作者は個人アカウントになっている。
- 外部からのコントリビュートを受けると、Issue・PR・レビュー・承認などで、個人アカウントが GitHub 上に出る場面がさらに増える。ADR 0005 でも、push した人として個人アカウントが見える場合があることは許容していた。
- 作者が避けたいのは、リポジトリ名やプラグイン名など、公開物の名前と表記が作者名になることである。コミットや GitHub 上の操作に個人アカウント名が出ることは問題にしない。

## Decision（決定）
- リポジトリ名・Organization 名・マーケットプレイス名・プラグイン名・スキル名・エージェント名に、作者の個人名や個人アカウント名を使わないこと。
- marketplace.json の `owner`、plugin.json の `author` と `repository`、LICENSE の著作者、README・CHANGELOG などの公開物の作者の表記は `kibako-works` にすること。個人のアカウント名や実名を書かないこと。
- コミットの作者・コミッター、PR・Issue・レビュー・マージなどの GitHub 上の操作者に、個人アカウントが出ることは許容する。GitHub の画面でのマージも禁止しない。
- コミットのメールアドレスには、`users.noreply.github.com` か GitHub が作るアドレス（`noreply@github.com`）以外を使わないこと。ローカルでのコミットは、引き続き `kibako-works <kibako-works@users.noreply.github.com>` で行うこと。
- 個人のメールアドレス・勤務先の情報・個人環境の絶対パスを公開物と履歴に書かないこと（CLAUDE.md の禁止事項は変えない）。
- 過去の履歴（`5de880b` を含む）は書き換えないこと。

## Consequences（結果）
- PR を必須にしても、GitHub の画面でのマージとの矛盾がなくなる。履歴を書き換える必要もない。
- git log と GitHub の画面から、作者の個人アカウント名が分かる。個人アカウント名は実名を元にしているので、作者の実名が推測できる状態になる。これは許容する。
- 公開物の名前と表記は `kibako-works` のままなので、プラグインの利用者が目にする名前は変わらない。
- ADR 0005 の決定のうち、Organization の下に置くこと、表記を `kibako-works` にすること、匿名用の個人アカウントを作らないことは、この ADR が引き継ぐ。

## 検証方法（任意）
- `git log --format='%ae%n%ce' | sort -u | grep -vE '@users\.noreply\.github\.com$|^noreply@github\.com$'` の結果が 0 件であること。
- `grep -rnE '"(name|owner|author)"' .claude-plugin/marketplace.json plugins/sdd/.claude-plugin/plugin.json` で出てくる作者の表記が、`kibako-works` だけであること。
- 作者の個人アカウント名で作業ツリーを検索し（`git grep -n -i <名前>`）、0 件であること。名前そのものは公開物に書かないため、検索語は手元で指定する。
