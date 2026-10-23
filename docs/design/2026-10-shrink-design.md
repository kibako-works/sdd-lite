# /sdd:design の縮小と Plan Mode の計画の利用

- Status: Implemented
- 作成日: 2026-10-23
- 関連 ADR: docs/adr/0009-design-principles.md、docs/adr/0011-lighter-default-and-ship-categories.md、docs/adr/0012-design-as-plan-form.md（T1 で起票）

## 1. 背景と目的
- `/sdd:design` は、Plan Mode の中で「1 問ずつ質問する → テンプレートで計画をまとめる → 承認を求める → 保存する」をすべて自分の手順として持っている。質問・計画・承認は、純正の Plan Mode がすでに持っている機能と重なる。ADR 0009 の原則 2（純正優先）に照らして、重なる部分を削りたい。
- design の retire-when は「Plan Mode が、デザインドキュメント形式の計画をリポジトリ内の Markdown として保存・承認できるようになったら削除」。公式の設定 `plansDirectory` で、計画をリポジトリ内に保存できるようになった（一部を満たす）。検証済みの事実（docs/design/2026-10-lighter-ship.md の Non-goals）では、次の 3 つが残る。
  - ファイル名にランダムな語尾が付く（例 calc-py-sub-purring-umbrella.md）。ファイル名を決める設定は無い（settings-reference、v2.1.308 で確認）。
  - 承認しても Status は変わらない。`/sdd:ask` と `/sdd:ship` は `- Status: Approved` で現在地と区分を判定している。
  - `plansDirectory` は全部の計画に効くので、区分 B・C の小さな計画も同じディレクトリに溜まる。
- 成功の定義:
  - `/sdd:design` が、計画に書式を与えることと、承認後に docs/design/ へ写して Status: Approved にすることだけを受け持つ。質問・計画・承認は Plan Mode に任せる。
  - 承認のときに「clear context」を選んでも、保存が漏れない。

## 2. スコープ
- やること:
  - design の SKILL.md を縮め、template.md の実装タスクの先頭に保存のタスク（T0）を置く。フロントマターの description・reviewed・retire-when を直す。
  - guide.md の §2-A を新しい流れに合わせる。
  - ADR 0012 を起票する。
  - plugin.json の version を 0.5.0 にし、CHANGELOG・README・README.ja.md（コマンドの説明と retire-when の表）を直す。
- やらないこと（Non-goals）:
  - `plansDirectory` を設定すること。既定（`~/.claude/plans`）のままにし、小さな計画をリポジトリに溜めない。
  - `/sdd:design` の廃止（ADR 0012 に代替案として記録する）。
  - フックによる自動のコピー（同上）。
  - init・ship・ask の SKILL.md と verifier の変更。ship が A に上げたときに Plan Mode の計画ファイルを要件として渡す手順（ADR 0011）は、そのまま使える。
  - docs/review-routine.md の変更。Routine はフロントマターの retire-when を読むので、文言を変えても手順は変わらない（確認のみ）。

## 3. 要件
- REQ-1: design の SKILL.md が、次の手順だけを持つこと。
  - Plan Mode で実行すること。質問・計画・承認は Plan Mode に任せること。
  - docs/design/ か docs/adr/ が無ければ `/sdd:init` を案内すること（今のまま）。
  - 計画ファイルを `${CLAUDE_SKILL_DIR}/template.md` に従って書き、Status を Draft にし、T0 に保存先の具体的なパス（`docs/design/YYYY-MM-<slug>.md`。年月は今日のもの）を書くこと。
  - 承認されたら、最初に T0 を実行すること。計画ファイルを T0 のパスに写し、Status を Approved にし、T0 にチェックを付けること。計画ファイルは消さないこと。
  - 代替案の比較などの重要な判断があれば `/sdd:adr` を提案すること（今のまま）。
  - 言語の段落（ADR 0010）は今のまま残すこと。
  - 1 問ずつ質問する手順、CLAUDE.md・コード・ADR を読む手順、承認を求める手順を持たないこと。
- REQ-2: template.md の実装タスクの先頭が、T0「この計画を docs/design/YYYY-MM-<slug>.md として保存し、Status を Approved にし、このタスクにチェックを付ける」であること。`- Status: Draft | Approved | Implemented` の行は変えないこと（ADR 0010 の検証方法）。
- REQ-3: design のフロントマターが次のとおりであること。README.md と README.ja.md の retire-when の表が、同じ内容であること。
  - description: Plan Mode の計画にデザインドキュメントの書式を与え、承認後に docs/design/ に保存する旨（Plan Mode で実行）。
  - reviewed: 実施日。
  - retire-when: 「Claude Code 純正の Plan Mode が、承認した計画を、決めたファイル名でリポジトリに保存し、承認済みの印を付けられるようになったら削除」（英語で書く）。
- REQ-4: guide.md の §2-A が新しい流れ（Plan Mode に入る → `/sdd:design` → Plan Mode の質問に答える → 計画を確かめる → Plan Mode で承認する → Claude が T0 で保存する）になっていること。guide.md が 160 行以下であること。§5・§6 の記述と矛盾しないこと。
- REQ-5: ADR 0012 が Accepted で、決定と、不採用の代替案（廃止して `plansDirectory: docs/design` にする・廃止して CLAUDE.md の規則で写す・フックで写す・承認後に書式へ整える）とその理由が書かれていること。
- REQ-6: plugin.json の version が 0.5.0 で、CHANGELOG.md に 0.5.0 が、README.md と README.ja.md に新しい説明が書かれていること。
- 非機能要件:
  - 予算: スキル＋エージェントは 6 のまま。guide.md は 160 行以下。`bash .github/scripts/check-principles.sh` が 0 で終わる。
  - 検証: `claude plugin validate --strict .` と `bash .github/scripts/check-public-files.sh` が通ること。ADR 0010 の検証方法（`..` を含むパスやシェル展開が無い、など）が通ること。
  - 互換性: 保存されるデザインドキュメントの形（Status・REQ-n・`- [ ]` の Tn）は今と同じにし、ask・ship・verifier の判定を変えない。

## 4. 設計
- 全体方針:
  - 質問・計画・承認は Plan Mode に任せる。`/sdd:design` は、計画の最初に書式を渡し、承認後の保存を指示するだけにする。
  - 書式は計画の前に渡す。承認したあとに整えると、承認した中身と保存した中身がずれるため。
  - 保存の指示は、計画そのものに T0 として書く。承認のときに「clear context」を選ぶと、スキルの指示は会話から消えるが、計画は残る。
  - 保存先のパスは計画を書くときに決めて T0 に書く。承認の前に、人がファイル名を確かめられる。
  - 計画ファイルは写すだけで消さない。計画ファイルはセッションのものであり、Claude Code が参照し続けることがあるため。
- 変更後の SKILL.md の骨子:
  - 0. docs/design/ か docs/adr/ が無ければ `/sdd:init` を案内する。
  - 1. 計画ファイルをテンプレートに従って書く（Status は Draft。T0 に具体的なパス）。
  - 2. 承認されたら最初に T0 を実行する（写す・Approved にする・T0 にチェック）。
  - 3. 重要な判断があれば `/sdd:adr` を提案する。
- 純正で代替できない理由（ADR 0009 の原則 2）:
  - `plansDirectory` で計画をリポジトリに保存できるが、ファイル名を決められず、承認しても Status が付かず、小さな計画も同じ場所に溜まる。
  - `/sdd:design` は、区分 A の計画だけに書式を与え、決めたファイル名で docs/design/ に写し、ask と ship が機械的に読める `- Status: Approved` を付ける。この 3 つは純正の機能では代わりにならない。
- retire-when: 純正の Plan Mode が、承認した計画を決めたファイル名でリポジトリに保存し、承認済みの印を付けられるようになったら削除する（REQ-3）。
- 検討した代替案と不採用の理由（ADR 0012 に記録する）:
  - 廃止し、init が `plansDirectory: docs/design` と CLAUDE.md の規則（書式と、承認後に改名して Approved にする）を書く: スキルは 1 つ減るが、小さな計画も docs/design/ にランダムな名前で溜まる。改名と Status の更新は Claude が規則を守るかに頼る。
  - 廃止し、`plansDirectory` は既定のまま、CLAUDE.md の規則で docs/design/ に写す: 計画は溜まらないが、確実さは上と同じく規則頼み。書式を CLAUDE.md に置くと、どのプロジェクトでも毎回のセッションでトークンを使う。
  - プラグインに PostToolUse(ExitPlanMode) のフックを置き、`- Status:` の行がある計画を自動で写す: 機械的で確実だが、スクリプトの保守が増える。日本語の題からの slug 作り・Windows 対応・予算の扱いを新しく決める必要がある。
  - 計画は自由な形で作り、承認後に `/sdd:design` が書式に整える: いちばん簡単だが、承認した中身と保存した中身がずれる。

## 5. 実装タスク
- [x] T1: `/sdd:adr` の手順で ADR 0012「/sdd:design は計画の書式と保存だけを受け持ち、質問・計画・承認は Plan Mode に任せる」を起票する（対応要件: REQ-5）
- [x] T2: design の SKILL.md と template.md を書き換え、フロントマターを直す（REQ-1〜REQ-3。README の表は T4）
- [x] T3: guide.md の §2-A を直し、160 行以下に収める（REQ-4）
- [x] T4: plugin.json を 0.5.0 にし、CHANGELOG.md・README.md・README.ja.md を直す（REQ-3, REQ-6）
- [x] T5: 一時的な git リポジトリで E2E を行う（REQ-1, REQ-2）。①`--permission-mode plan` と `--settings '{"plansDirectory": ".plans"}'` で `/sdd:design` を実行し、計画ファイルがテンプレートの形・Status: Draft・T0 に具体的なパスを持ち、docs/design/ にはまだ何も無いことを確かめる。②①のセッションを `--resume` し、承認の旨を伝えて続け、T0 のパスに Status: Approved・T0 にチェック付きで保存され、計画ファイルが残ることを確かめる。③clear context の代わりに、新しいセッションに計画の本文だけを渡して実装を頼み、最初に T0 が実行されることを確かめる

## 6. テスト・検証方法
- 共通（タスクごと）: `claude plugin validate --strict .`、`bash .github/scripts/check-principles.sh`、`bash .github/scripts/check-public-files.sh` が通ること。
- REQ-1・REQ-2: SKILL.md と template.md を読んで確かめる。T5 の①〜③。`grep -n 'Status: Draft | Approved | Implemented' plugins/sdd/skills/design/template.md` が 1 件。`` grep -rnE '\.\./|!`' plugins/ `` が 0 件。
- REQ-3: フロントマターと README の表（英語版・日本語版）を読んで確かめる。
- REQ-4: §2-A を読んで確かめる。`wc -l plugins/sdd/skills/ask/guide.md` が 160 以下。
- REQ-5: ADR 0012 を読んで確かめる。
- REQ-6: `grep '"version": "0.5.0"' plugins/sdd/.claude-plugin/plugin.json`、CHANGELOG と README（英語版・日本語版）の該当の節を読んで確かめる。
- 制約: `claude -p` では、権限の受け手が無いと `ExitPlanMode` が出ないため、Plan Mode の承認の画面そのものは T5 では試せない。②の `--resume` での承認と、③の新しいセッションで代える。対話での確認は、必要なら作者が 1 回行う。

## 7. 未決事項
- なし。
- 追記（T5 の結果、Claude Code v2.1.308）: 一時的な git リポジトリ（Python、main）で、`--setting-sources project,local` を付けて試した。
  - ①`--permission-mode plan` と `--settings '{"plansDirectory": ".plans"}'` で `/sdd:design`（sub を足す）を実行した。計画ファイルは `.plans/add-a-sub-a-b-hidden-marble.md`（ランダムな語尾付き）になり、テンプレートの形・Status: Draft・T0 に `docs/design/2026-10-sub-function.md` を持っていた。docs/design/ は空だった。`ExitPlanMode` は出ず、会話で承認を求めた（想定どおり）。
  - ②①のセッションを `--resume` し、`--permission-mode acceptEdits` で承認を伝えた。最初に T0 を実行し、`docs/design/2026-10-sub-function.md` を Status: Approved・T0 にチェック付きで保存した。計画ファイルとの差は、Status と T0 のチェックだけだった。計画ファイルは残った。`grep -l '^- Status: Approved' docs/design/*.md` で見つかった。
  - ③リポジトリを戻し、新しいセッション（`plansDirectory` なし）に計画の本文だけを渡して実装を頼んだ。スキルの指示が無くても、最初に T0 を実行し、Status: Approved・T0 にチェック付きで保存した。
