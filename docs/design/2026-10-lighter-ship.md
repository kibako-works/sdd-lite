# 軽い方への反転と ship の段階化

- Status: Approved
- 作成日: 2026-10-23
- 関連 ADR: docs/adr/0009-design-principles.md、docs/adr/0011-lighter-default-and-ship-categories.md（T1 で起票）

## 1. 背景と目的
- guide.md の規模の判断は「迷ったら上の区分（重い方）を選ぶ」「迷ったら B にして ADR を残す」になっている。ADR 0009 の原則 1（軽さ：迷ったら軽い方を選び、必要になったら上げる）に反し、ADR 0009 の Consequences に既知の違反として記録してある。
- `/sdd:ship` は、変更の大きさによらず verifier・`/simplify`・`/code-review` をすべて実行する。文言の修正 1 行でも同じ手間とトークンがかかる。
- 軽い方を既定にすると、ADR や設計が漏れるおそれが増える。安全網として、ship の「ADR 漏れの確認」と、Plan Mode 中に区分を上げる規則を置く。
- 成功の定義:
  - guide の判断基準が「迷ったら軽い方・必要になったら上げる」になり、上げる条件が書かれている。guide は予算（160 行）に収まっている。
  - ship が、計画のときに作った成果物から区分（A / B / C）を機械的に決め、差分の中身で上げるだけ上げ、区分に応じた手順だけを実行する。

## 2. スコープ
- やること:
  - guide.md の §1（規模の判断）・§2-C・§2-D・§3（完了時の手順）・§4 を、軽い方を既定にする判断基準と ship の区分に合わせて直す。
  - ship の SKILL.md に、区分の判定・宣言・上書き・区分ごとの手順を書く。
  - verifier に、ADR との整合だけを確かめる使い方を足す。
  - ADR 0011 を起票し、ADR 0009 に違反の解消を追記する。
  - plugin.json の version を 0.4.0 にし、CHANGELOG・README・README.ja.md を直す。
- やらないこと（Non-goals）:
  - `/sdd:design` の縮小・廃止と `plansDirectory` の利用。別のデザインドキュメントで扱う。参考として検証済みの事実: `plansDirectory` を `docs/design` にすると Plan Mode の計画がリポジトリに保存され、CLAUDE.md で形式（Status・REQ-n・Tn など）を指定すると従う。ただしファイル名にランダムな語尾が付き、承認しても Status は変わらず、小さな計画も溜まる。
  - `/sdd:ask` の SKILL.md と、現在地の判定（guide §6）の変更。
  - `git diff --stat`（変更量）を区分の判定に使うこと。改行の追加だけの大きな差分や、1 行でも全体に効く設定値の変更を誤って判定するため。

## 3. 要件
- REQ-1: guide.md の §1 が「迷ったら軽い方の区分を選び、必要になったら上げる」になっていること。「迷ったら上の区分」「迷ったら B」の記述が無いこと。
- REQ-2: guide.md の §2-C に、Plan Mode で計画している間に区分を上げる規則があること。設計判断が出てきたら先に `/sdd:adr` で ADR を残す（B に上げる）。要件の整理が要る・新しい機能になると分かったら `/sdd:design` に切り替える（A に上げる）。
- REQ-3: ship が、次の規則で基本の区分を決めること。
  - A: `Status: Approved` のデザインドキュメントがある。
  - B: A ではなく、このブランチ（既定のブランチとの差分と、コミットしていない変更）で docs/adr/ に ADR が追加されている。
  - C: どちらでもない。
- REQ-4: ship が、空白の違いを無視した差分の中身（`git diff -w`）を読み、設定値・共有の定数・公開 API・スキーマやマイグレーション・依存関係・セキュリティ（認証・権限・秘密情報・入力の検証）や、プロジェクトの CLAUDE.md に「重い場所」として書かれた場所に触れていれば、区分を 1 段上げること。下げないこと。変更量（行数・ファイル数）は判定に使わないこと。
- REQ-5: ship が、手順を始める前に、区分と理由を 1 行で宣言すること。利用者は `/sdd:ship <A|B|C>` の引数か、会話での指示で区分を上書きできること。宣言のあとに承認を待たないこと（承認は設計と PR の 2 回まで。ADR 0009 の原則 1）。
- REQ-6: ship が、区分ごとに次の手順を実行すること。
  - 全区分: テスト・lint・型チェック、`/code-review`（C は `/code-review low`、A・B は level を指定しない）、ADR の漏れの確認、文書の更新、承認を得てからのコミットと PR の作成。
  - A: verifier でデザインドキュメントの要件と照合する。`/simplify` を実行する。
  - B: verifier で ADR との整合だけを確かめる。`/simplify` は、差分に関数・クラス・モジュールの追加か、数行を超えるロジックの変更があるときだけ実行する（文書や設定値だけなら省く）。
  - C: verifier と `/simplify` を省く。
  - A に上がったがデザインドキュメントが無いときは、verifier に Plan Mode の計画ファイルと関係する ADR を要件として渡す。
- REQ-7: verifier が、ADR との整合だけを頼まれたときは、要件の照合を省き、差分が Accepted な ADR に反していないかだけを報告すること。
- REQ-8: ADR 0011 が Accepted で、ADR 0009 の Consequences に違反の解消が追記されていること。
- REQ-9: plugin.json の version が 0.4.0 で、CHANGELOG.md に 0.4.0 が、README.md と README.ja.md に ship の区分の要点（区分の決め方・上書きの方法）が書かれていること。
- 非機能要件:
  - 予算: guide.md が 160 行以下。`bash .github/scripts/check-principles.sh` が 0 で終わる。変えたスキルとエージェントの `reviewed` を実施日に更新する。
  - 正本: 区分の判定と手順の正本は ship の SKILL.md に置き、guide には流れと使い分けだけを書く（ADR 0010 が引き継いだ「SKILL.md が手順の正本」）。
  - 検証: `claude plugin validate --strict .` と `bash .github/scripts/check-public-files.sh` が通ること。

## 4. 設計
- 全体方針:
  - 区分の名前（A / B / C）は guide §1 のものをそのまま使う。計画のときの区分と ship の区分が同じ意味になり、ask の案内とも食い違わない。
  - 基本の区分は、計画のときに残した成果物（デザインドキュメント・ADR）で機械的に決める。人が計画のときに選んだ区分が、成果物を通じて ship に伝わる。
  - 差分の中身で上げるのは、成果物が軽すぎた場合の安全網。上げるだけで下げないので、成果物を作ったのに手順が軽くなることは無い。
  - 宣言のあとに承認を待たない。上書きしたい人は引数で渡すか、宣言を見て止める。
- ship の手順（変更後の SKILL.md の骨子）:
  - 0. 区分を決めて宣言する（REQ-3〜REQ-5）。git の外では差分が無いので、デザインドキュメントがあれば A、無ければ利用者に聞く。
  - 1. A なら verifier（要件の照合）、B なら verifier（ADR との整合）、C なら省く。
  - 2. テスト・lint・型チェック。
  - 3. `/simplify`（A は常に、B は条件付き、C は省く）と `/code-review`（C は low）。
  - 4〜6. ADR の漏れの確認、文書の更新、コミットと PR（今のまま）。
- guide の変更:
  - §1: 「When in doubt, choose the lower category, and move up when needed (see 2-C).」に変え、B の説明の「When in doubt, choose B」を消す。
  - §2-C: 計画の途中で上げる規則を 1 項目足す。
  - §3: 完了時の手順の表に、区分ごとに実行するかの列を足すか、表の下に区分ごとの省略を 2〜3 行で書く。詳しい規則は ship の SKILL.md を見るよう書く。
  - §4: 「デザインドキュメントが無いとき 3-1」の行を、区分 B・C の扱いに合わせる。
- 検討した代替案と不採用の理由（ADR 0011 に記録する）:
  - 変更量（`git diff --stat`）で区分を決める: 改行の追加だけの大きな差分を重く、1 行の設定値の変更を軽く判定してしまう。
  - 区分を毎回利用者に聞く: 承認が 1 回増え、原則 1 に反する。
  - ship を段階化せず、guide の判断基準だけを反転する: ship の手間は変わらず、軽くする効果が小さい。
  - 差分の中身で区分を下げることも認める: 成果物を作った判断を ship が覆すことになり、安全網として働かない。

## 5. 実装タスク
- [x] T1: `/sdd:adr` の手順で ADR 0011「規模は軽い方を既定にし、ship を区分で段階化する」を起票し、ADR 0009 に違反の解消を追記する（対応要件: REQ-8）
- [ ] T2: ship の SKILL.md を書き換え、引数で区分を上書きできるよう argument-hint を足す。verifier に ADR との整合だけを確かめる使い方を足す（REQ-3〜REQ-7）
- [ ] T3: guide.md の §1・§2-C・§3・§4 を直し、160 行以下に収める（REQ-1, REQ-2）
- [ ] T4: plugin.json を 0.4.0 にし、CHANGELOG.md・README.md・README.ja.md を直す（REQ-9）
- [ ] T5: 一時的な git リポジトリで `--plugin-dir` と `claude -p` を使い、コミットの直前で止める指示を付けて `/sdd:ship` を実行し、宣言された区分と実行した手順を確かめる。①文言の修正だけ（C、verifier と `/simplify` なし、`/code-review low`）②ADR を追加したブランチ（B）③依存関係のファイルを変えた修正（C から B に上がる）④Approved のデザインドキュメントあり（A）⑤`/sdd:ship C` で上書き（REQ-3〜REQ-6）

## 6. テスト・検証方法
- 共通（タスクごと）: `claude plugin validate --strict .`、`bash .github/scripts/check-principles.sh`、`bash .github/scripts/check-public-files.sh` が通ること。
- REQ-1・REQ-2: `grep -n 'When in doubt' plugins/sdd/skills/ask/guide.md` で、軽い方を選ぶ 1 件だけが出ること。§2-C に上げる規則があることを読んで確かめる。`wc -l` が 160 以下。
- REQ-3〜REQ-6: T5 の 5 通りで、宣言された区分と理由、実行された手順（verifier・`/simplify`・`/code-review` の level）が規則どおりであること。
- REQ-7: T5 の②で、verifier の報告が ADR との整合だけになっていること。
- REQ-8: ADR 0011 と 0009 を読んで確かめる。
- REQ-9: `grep '"version": "0.4.0"' plugins/sdd/.claude-plugin/plugin.json`、CHANGELOG と README（英語版と日本語版）の該当の節を読んで確かめる。

## 7. 未決事項
- なし。
