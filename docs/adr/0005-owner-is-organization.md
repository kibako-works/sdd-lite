# 0005. 公開物の所有者と作者の表記は Organization kibako-works にする

- Status: Superseded by 0007
- 日付: 2026-10-20
- 関連: docs/design/2026-10-initial-release.md

## Context（背景）
- 当初は、リポジトリを作者の個人アカウントの下に置き、マニフェスト・LICENSE・README・コミットの作者を GitHub のユーザー名で書く予定だった。ユーザー名は作者の実名を元にしており、公開物から個人が分かる。
- 作者は、今後開発するもののうち、公開するものや非公開で商用に使うものを、1 か所にまとめたい。
- 匿名用に別の個人アカウントを作る方法は、GitHub の利用規約（無料の個人アカウントは 1 人 1 つまで）に反するおそれがある。
- 個人アカウントのユーザー名を変える方法は、既存の別のリポジトリの URL や noreply アドレスまで変わり、影響が大きい。
- コミットの作者のメールに個人の普段のアドレスを使うと、public にしたときに誰でも読めるうえ、GitHub がそのコミットを個人アカウントにひも付けて表示する。

## Decision（決定）
- リポジトリは GitHub の Organization `kibako-works` の下に置くこと。インストールは `/plugin marketplace add kibako-works/sdd-lite` で行う。
- marketplace.json の `owner`、plugin.json の `author` と `repository`、LICENSE の著作者、README は `kibako-works` で書くこと。個人のアカウント名や実名を書かないこと。
- コミットの作者とコミッターは `kibako-works <kibako-works@users.noreply.github.com>` にすること。個人のメールアドレスや、個人アカウントの noreply アドレスを使わないこと。
- 公開前の履歴も、この作者に書き換えること。
- 匿名用の個人アカウントを新しく作らないこと。

## Consequences（結果）
- 公開物と履歴から、作者の個人名が分からなくなる。
- コミットの作者のメールは GitHub のアカウントにひも付かないので、コミットにアイコンやプロフィールへのリンクは表示されない。
- push は個人アカウントで行うため、リポジトリの Activity などで、push した人として個人アカウントが見える場合がある。外から見える表記を変える決定であり、完全な匿名化ではない。これは許容する。
- 履歴を書き換えるので、タグを付け直す必要がある。force push では、書き換える前のコミットが SHA を指定すれば取り出せる状態で GitHub に残り、Activity にも記録される。そのため、公開前に一度だけ、リポジトリを削除して作り直し、書き換えたあとの履歴を push する。
- 今後のプロジェクトも同じ Organization にまとめられる。商用で使う段階で、有料プランへの切り替えやメンバーの追加ができる。

## 検証方法（任意）
- `git log --format='%an <%ae>|%cn <%ce>' | sort -u` の結果が、`kibako-works <kibako-works@users.noreply.github.com>|kibako-works <kibako-works@users.noreply.github.com>` の 1 行だけであること。
- 作者の個人アカウント名で、作業ツリー（`git grep -n -i <名前>`）と履歴（`git log -p --all -i -G <名前>`）を検索し、0 件であること。名前そのものは公開物に書かないため、検索語は手元で指定する。
