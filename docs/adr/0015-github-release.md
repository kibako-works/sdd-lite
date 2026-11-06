# 0015. リリースのたびに、軽量タグに加えて GitHub Release を作る

- Status: Accepted
- 日付: 2026-11-06
- 関連: docs/adr/0008-main-protection-and-distribution.md、docs/adr/0010-native-language.md、docs/adr/0002-distribute-as-plugin.md

## Context（背景）
- これまでのリリースは、CHANGELOG.md に追記してタグ `vX.Y.Z` を付けるだけで、GitHub Release は作っていない（v0.7.0 の時点で 0 件）。変更点は CHANGELOG.md にしか無い。
- このリポジトリは公開マーケットプレイスとして配布している。利用者は CHANGELOG を開かないと変更点がわからず、リリースの通知も届かない。
- 既存のタグの種類は混ざっている。v0.1.0・v0.2.0 は注釈付きタグで、v0.3.0〜v0.7.0 は軽量タグである。
- タグは Ruleset `protect-tags` で更新と削除が禁止されていて、作り直せない（ADR 0008）。
- 配布は main を相対パス `./plugins/sdd` で指していて、導入済みの利用者への更新は plugin.json の `version` で決まる。タグも Release も配布には使っていない（ADR 0008）。

## Decision（決定）
- タグは今後も軽量タグにすること。既存のタグは作り直さないこと。
- リリースのたびに、タグに加えて GitHub Release を作ること。
- Release の本文は、CHANGELOG.md のその版の節をそのまま写すこと。手で書き直さないこと。本文は英語とすること（ADR 0010）。
- 「Latest」は、CHANGELOG のいちばん新しい版の Release にだけ付けること。
- Release を作るときに、新しいタグを作らないこと。タグはその前の段で付けること。
- 既存のタグ v0.1.0〜v0.7.0 にも、Release をさかのぼって作ること。
- 配布の仕組み（marketplace.json・plugin.json）は変えないこと。

## Consequences（結果）
- Releases のページと通知で、利用者に変更点が届く。
- リリースの手順が 1 つ（Release の作成）増える。
- Release の日付は作成した日になる。さかのぼって作る Release も同じで、リリースの日付は CHANGELOG の日付が正しい。
- CHANGELOG を直しても、Release の本文は自動では変わらない。直すときは Release の本文も直す。
- 配布と更新の届き方は変わらない。
- 検討した代替案と、採らなかった理由:
  - 注釈付きタグにする：既存のタグを作り直せないので、種類はそろわない。注釈付きタグの利点（手元で読めること、署名）は、いまは必要ない。
  - 今のまま（タグだけ）：変更点が CHANGELOG にしか無く、通知も届かない。

## 検証方法（任意）
- `git ls-remote --tags origin` のタグごとに、同じ名前の Release があること（`gh release list`）。
- Latest の Release が、CHANGELOG のいちばん上の版であること（`gh release view --json tagName`）。
