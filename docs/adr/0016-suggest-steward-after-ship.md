# 0016. sdd:ship は純正 /ship を呼ばず、PR の作成後に /steward を案内する

- Status: Accepted
- 日付: 2026-11-25
- 関連: docs/adr/0009-design-principles.md、docs/adr/0011-lighter-default-and-ship-categories.md

## Context（背景）
- Claude Code に、純正の `/ship`（裏のスキル名は `ship-local`）と `/steward` が入った。`/ship` は、コミット・push・PR の作成、`/code-review` によるレビュー、PR の見張り（CI の失敗・競合・レビューのコメントに対応して修正を push する。最長 7 日）を行う。`/steward` はレビューを飛ばし、開いている自分の PR の見張りだけを始める。
- ADR 0009 の原則 2（純正優先）に照らして、`sdd:ship` の手順のうち純正で置き換えられる部分を置き換え、`sdd:ship` の中から純正の `/ship` を呼んで続けさせる案を検討した。
- 2026-11-25 に作者の手元で確かめたこと:
  - `/ship` は、ユーザーが自分で打ったときだけ起動する。Claude は Skill ツールから呼べない。
  - `/ship` が使えるのは v2.1.330 以上で、この時点では latest のチャネルにしか無い（stable は 2.1.326）。
  - クラウドのセッション（claude.ai/code）には `/ship`・`/steward` が無い。
  - `/steward` は、公式ドキュメントで `/ship` と同じページに載り、同じ要件（v2.1.330 以上）を持つ。Claude から呼べるかは確かめていないが、この ADR では `/ship` と同じく、Claude から起動させない。
- 純正の `/ship` は、区分の判定・デザインドキュメントとの照合（verifier）・テストの実行・ADR の漏れの確認・デザインドキュメントの更新をしない。最初の push は確認なしで進み（数秒待つだけ）、auto mode では見張りの間の修正も聞かずに push する。PR の本文を指定する引数も無い。

## Decision（決定）
- `sdd:ship` の手順 0〜6 は変えないこと。承認の前の `/code-review`、承認の後の push と `gh` による PR の作成も、今のまま `sdd:ship` で行うこと。
- `sdd:ship` から純正の `/ship`・`/steward` を呼ぼうとしないこと。
- PR を作った後に、`/steward` が使える環境なら、ユーザーが自分で `/steward` を打てば CI とレビューのコメントへの対応を任せられることを、1 行で案内すること。auto mode では修正を聞かずに push することも、あわせて伝えること。使うかどうかはユーザーに任せること。
- 案内するのは `/ship` ではなく `/steward` とすること。`/ship` はレビューをやり直すので、承認の前の `/code-review` と二重になる。
- `sdd:ship` の retire-when は変えないこと。純正の `/ship` は検証と ADR の確認をしないので、撤去の条件を満たさない。

## Consequences（結果）
- `/steward` が使える環境では、PR の後の CI やレビューへの対応を純正に任せられる。承認の回数は増えない（ADR 0009 の原則 1）。
- `/steward` が無い環境（stable のチャネル、クラウドのセッション、古い版）でも、`sdd:ship` の動きは今と変わらない。
- `/steward` を使うと、PR の承認の後に、人が見ていない修正が push されうる。案内の中で伝え、判断は利用者に任せる。このリポジトリでの開発では、CLAUDE.md の「push は人間の確認なしに行わない」に従い、auto mode で `/steward` を使わない。
- 純正の `/ship` が Claude から呼べるようになるか、検証・ADR の確認をするようになったら、この判断を見直す。
- 検討した代替案と、採らなかった理由:
  - `sdd:ship` の中から純正の `/ship` を呼ぶ：Claude からは呼べない。
  - 手順 3 の `/code-review` をやめ、PR の後に `/ship <level> <PR番号>` を打つよう案内する：ユーザーが打たなければレビューが抜ける。ADR 0011 の区分ごとのレビューも変える必要がある。
  - 何もしない：PR の後の対応を純正に任せられることが、利用者に伝わらない。

## 検証方法（任意）
- `grep -n 'steward' plugins/sdd/skills/ship/SKILL.md` の結果が 1 件以上であること。
- `plugins/sdd/skills/ship/SKILL.md` に、`/ship` や `/steward` を Claude が起動する指示が無いこと。
