# 設計原則の明文化と予算チェック

- Status: Approved
- 作成日: 2026-10-22
- 関連 ADR: docs/adr/0007-design-principles.md（T1 で起票）、docs/adr/0001-record-architecture-decisions.md

## 1. 背景と目的
- sdd-lite は「cc-sdd の承認・トークン・文書量の重さから抜け出す」「純正機能を優先し、自作は足りない部分だけにして、純正に同等機能が出たら速やかに外す」という思想で始めた。原案（2026-09-30 の調査資料）は、design・adr・ship の 3 スキルと verifier、承認は「設計」と「PR」の 2 回、ADR は大規模の変更だけ、1 か月後に見直す、という構成だった。
- 1 か月で ask・init・多言語対応（userConfig）が増え、guide.md はプラグインで最大のファイルになり、判断基準は「迷ったら重い方」に寄った。追加の一つ一つは妥当だったが、思想がリポジトリの外（非公開の調査資料と作者の頭の中）にしか無く、追加のたびに照らす物差しと、見直しを実行させる仕組みが無かった。
- 成功の定義:
  - 原則がリポジトリ内の Accepted な ADR として残り、CLAUDE.md から毎回参照される。原則を変えるには新しい ADR が要る。
  - 予算（スキル数・guide の大きさ・撤去条件・見直しの鮮度）の違反を、ローカルと CI で機械的に検出できる。
  - 月 1 回、PC を開いていなくても、純正機能の更新と各スキルの retire-when が突き合わされ、撤去候補や見直し切れがあれば Issue で知らされる。

## 2. スコープ
- やること:
  - ADR 0007「設計原則」を起票する（原則・予算・原案の要点を Context に書き写す）。
  - 予算チェックのスクリプト `scripts/check-principles.sh` を作る。
  - GitHub Actions で push と PR のたびにスクリプトを実行する。
  - CLAUDE.md に原則の要約 3 行・ADR 0007 へのリンク・検証コマンドを足す。
  - 月 1 回の見直しの手順書をリポジトリに置き、それを読む Routine（cloud scheduled task）を `/schedule` で登録する。
- やらないこと（Non-goals）:
  - 既存の原則違反の解消。userConfig の言語設定（原則 2 に反する）は次のデザインドキュメント「純正 language 設定への統合」で、guide.md の「迷ったら重い方」（原則 1 に反する）はその次の「軽い方への反転と ship の段階化」で直す。この ADR では既知の違反として記録するだけにする。
  - プラグイン本体（plugins/）の変更。利用者に届く変更が無いので、version は上げない。
  - Routine による自動のコード変更・push・PR 作成。
  - `claude plugin validate` の CI 化（CI に Claude Code を入れる必要があり、今回の範囲を超える）。

## 3. 要件
- REQ-1: docs/adr/0007 に、次の原則が「〜すること / 〜しないこと」の形で Accepted として書かれていること。
  - 原則 1（軽さ）: 人間の承認は「設計の承認」と「PR」の 2 回までにすること。規模の判断に迷ったら軽い方を選び、必要になったら上げること。
  - 原則 2（純正優先）: 純正機能で代替できるものを作らないこと。スキル・エージェント・設定・補助ファイルを足すときは、デザインドキュメントに「純正で代替できない理由」と retire-when を書くこと。
  - 原則 3（速やかな撤去）: すべてのスキルとエージェントに `retire-when` と `reviewed` を持たせ、定期的に見直すこと。
  - 原則 4（ツール非依存）: 成果物（デザインドキュメント・ADR）は素の Markdown にし、特定ツールの形式に依存させないこと。
  - 予算: スキルとエージェントの合計は 6 以下、guide.md は 160 行以下、`reviewed` は 60 日以内。予算を変えるには新しい ADR が要る。
- REQ-2: ADR 0007 の Context に、原案の要点（cc-sdd で疲弊した点、Anthropic・AWS/Spotify・Google・Shopify から取り入れたこと、当初の構成）が書かれていること。
- REQ-3: `scripts/check-principles.sh` が、次のどれかに当てはまると 0 以外で終わり、当てはまる項目をすべて表示すること。当てはまらなければ 0 で終わること。
  - `plugins/sdd/skills/*/SKILL.md` と `plugins/sdd/agents/*.md` の数の合計が 6 を超える
  - `plugins/sdd/skills/ask/guide.md` が 160 行を超える
  - スキルかエージェントのフロントマターに `retire-when:` か `reviewed:` が無い
  - `reviewed:` の日付が、実行日から 60 日より前
- REQ-4: GitHub Actions が、main への push とすべての PR で REQ-3 のスクリプトを実行し、失敗したらチェックが赤になること。
- REQ-5: CLAUDE.md の「プロジェクト概要」に原則の要約と ADR 0007 へのリンクがあり、「よく使うコマンド」の検証にスクリプトが入っていること。
- REQ-6: 月 1 回の Routine が、リポジトリ内の手順書に従って、Claude Code の公式の変更履歴と各スキルの `retire-when` を突き合わせ、撤去候補か予算違反（REQ-3）があるときだけ GitHub Issue を立てること。コードの変更・push・PR 作成はしないこと。
- 非機能要件:
  - 移植性: スクリプトは bash と標準的なコマンド（grep・awk・date）だけで動き、GNU（Linux・WSL・CI）と BSD（macOS）の `date` の両方で日付を計算できること。
  - テストしやすさ: 対象のルートを引数で、実行日を環境変数で差し替えられること。
  - 公開物の制約: 作者の個人情報や個人環境の絶対パスを、スクリプト・ワークフロー・手順書・Issue に書かないこと。

## 4. 設計
- 全体方針:
  - 原則の正本は ADR 0007。CLAUDE.md は要約とリンクだけを持ち、内容を重複させない（ADR 0006 の「README に guide の表を重複させない」と同じ考え方）。
  - 見張りは 3 層にする。①毎回読まれる CLAUDE.md（原則の要約）、②変更のたびの CI（予算）、③月 1 回の Routine（純正機能の更新と撤去条件の突き合わせ）。
  - 既存の仕組みを再利用する。「Accepted な ADR に反する実装をしない／反するなら Superseded にする ADR を先に出す」という CLAUDE.md と ADR 0001 の規則がそのまま原則の見張り役になる。
- ファイル構成（追加・変更）:
  - `docs/adr/0007-design-principles.md`（新規）
  - `scripts/check-principles.sh`（新規）: `ROOT=${1:-.}`、`TODAY=${CHECK_TODAY:-$(date +%F)}`。予算の値はスクリプトの先頭に定数で置き、ADR 0007 の番号をコメントで示す。
  - `.github/workflows/check-principles.yml`（新規）: `ubuntu-latest` で checkout してスクリプトを実行するだけ。
  - `docs/review-routine.md`（新規）: Routine が読む手順書。①スクリプトを実行する ②公式の変更履歴（code.claude.com/docs の changelog と What's new）で、前回の実行以降の変更を読む ③各スキルの `retire-when` と突き合わせる ④撤去候補か違反があれば、Issue を 1 件立てる（同じ月の Issue が既にあれば追記する）⑤何も無ければ何もしない。
  - `CLAUDE.md`（変更）: 概要に原則 3 行と ADR 0007 へのリンク、コマンドに `bash scripts/check-principles.sh`。
  - Routine（リポジトリ外・claude.ai の設定）: 毎月 1 日 9:07 に実行。プロンプトは「docs/review-routine.md の手順に従う」だけにして、手順の正本をリポジトリに置く。
- 検討した代替案と不採用理由:
  - 原則を CLAUDE.md だけに書く: 毎回読まれるが、変えるときに理由が残らず、なし崩しに書き換わる。ADR にすれば変更に Superseded の手続きが要る。
  - Routine だけで予算を見る: 月 1 回なので、違反が 1 か月混ざり続ける。変更のたびに止まらない。
  - Routine が下書き PR を作る: 人間の確認なしに push が起きるので、CLAUDE.md の禁止事項に反する。
  - `/loop` や Desktop の scheduled tasks: PC を開いていないと動かない。

## 5. 実装タスク
- [x] T1: `/sdd:adr` で ADR 0007「設計原則」を起票する。Context に原案の要点、Decision に原則 1〜4 と予算、Consequences に既知の違反（userConfig の言語設定、guide.md の「迷ったら重い方」）と、それを直すデザインドキュメントを書く（対応要件: REQ-1, REQ-2）
- [x] T2: `scripts/check-principles.sh` を作る。今のリポジトリで 0 で終わることと、違反を仕込んだ一時的なコピーで 0 以外になることを確かめる（REQ-3）
- [ ] T3: `.github/workflows/check-principles.yml` を作る（REQ-4）
- [ ] T4: CLAUDE.md に原則の要約・リンク・検証コマンドを足す（REQ-5）
- [ ] T5: `docs/review-routine.md` を作る（REQ-6）
- [ ] T6: PR を作って CI が緑になることを確かめる。マージ後に `/schedule` で Routine を登録し、手動で 1 回実行して、Issue を立てない（または意図どおり立てる）ことを確かめる。push・PR・Routine の登録は人間の確認を取ってから行う（REQ-4, REQ-6）

## 6. テスト・検証方法
- REQ-1・REQ-2: ADR 0007 を読み、原則 1〜4・予算・原案の要点があること、Status が Accepted であることを確かめる。
- REQ-3: 次をすべて確かめる。
  - 今のリポジトリで `bash scripts/check-principles.sh` が 0 で終わる。
  - 一時的なコピー（スクラッチ領域）で、スキルを 1 つ足す／guide.md を 161 行にする／SKILL.md から `retire-when:` を消す、をそれぞれ行うと 0 以外で終わり、該当項目が表示される。
  - `CHECK_TODAY=2027-01-01` で実行すると、`reviewed: 2026-10-20` が期限切れとして検出される。`CHECK_TODAY=2026-12-19`（60 日後）では検出されない。
  - `shellcheck` が使えれば警告が無いこと。
- REQ-4: T6 の PR で、ワークフローが実行されて緑になること。
- REQ-5: `grep -n 'check-principles' CLAUDE.md` と `grep -n '0007' CLAUDE.md` が 1 件以上であること。
- REQ-6: Routine を手動で 1 回実行し、実行履歴で手順書のとおりに進んだことと、コードの変更や push が無いことを確かめる。
- 共通: `claude plugin validate --strict .` が警告なしで通ること（plugins/ は変えないが、念のため）。

## 7. 未決事項
- Routine の既定の cloud environment（Trusted のネットワーク）から code.claude.com を読めるか、Issue を立てる権限（Claude GitHub App）があるかは、T6 で確かめる。読めない・立てられない場合は、environment の許可リストか GitHub App の導入を人間が行う。
- `reviewed` の期限切れで CI が赤になると、無関係な PR も止まる。見直しを強制するための意図した挙動とし、見直しの結果は `reviewed` の日付を更新する 1 行の変更で反映する。運用して煩わしければ、新しい ADR で警告に格下げする。
