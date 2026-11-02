# kome-oroshi-app での試験運転を受けた改善（承認疲れの是正ほか）

- Status: Implemented
- 作成日: 2026-11-02
- 関連 ADR: docs/adr/0009-design-principles.md、docs/adr/0011-lighter-default-and-ship-categories.md、docs/adr/0012-design-as-plan-form.md、docs/adr/0013-no-approval-within-approved-plan.md（T1 で起票）

## 1. 背景と目的
- kome-oroshi-app で、kiro（cc-sdd）から sdd 0.5.0 に移行し、試験運転した（2026-11-02、PR #177・#178）。流れは最後まで回ったが、移行のセッションでは、Plan Mode での計画の承認を除いても、人間の承認や判断を求めて 7 回止まった。ADR 0009 の原則 1 は「承認は設計と PR の 2 回まで」である。ユーザーからは、タスクごとの確認や「次に進んでよいですか？」が非常にストレスだった、という声があった。
- 原因は次のとおり。
  - adr の SKILL.md のステップ 4 と、guide の §2-A の 6 が、承認済みの計画の中の ADR のタスクにも承認を求めている。
  - CLAUDE.md のテンプレートに、承認のあとはタスクの間で止まらずに進める、という指示が無い。
  - init は、既存の CLAUDE.md に「Common commands」を追記しない。そのため、ステップ 0-5 で不足が分かり、追加の確認が 3 往復発生した。
  - ship は「CLAUDE.md で要注意とされた場所」を区分を上げる条件にしているが、テンプレートにその節が無い。kome では「Places needing care」という節を自分で作った。
  - ask が、人間しか起動できない `/sdd:design` を長い引数ごと案内した。それをそのまま貼ったら貼り付けとして扱われ、コマンドが起動しなかった。
  - README に、クラウド（claude.ai/code）で使う方法が書かれていない。そのため、「プラグインはクラウドで使えない」と判断してスキルをリポジトリにコピーする作業をし、あとで捨てた。実際には、claude.ai で追加したプラグインが `sdd@synced` としてクラウドでも読み込まれた。
- 成功の定義:
  - 区分 A の流れで人間が止められるのは、設計の承認と PR の承認の 2 回だけになる。例外は、計画からはずれたとき、Accepted な ADR とぶつかったとき、人間にしかできない確認があるときに限る。
  - init を 1 回承認するだけで、後の手順に必要な CLAUDE.md の節がそろう。
  - README を読めば、クラウドで sdd を使う方法が分かる。

## 2. スコープ
- やること:
  - adr の SKILL.md：承認済みの計画のタスクとして記録するときは、確認せずに保存する。
  - CLAUDE.md のテンプレート：「承認後はタスクの間で確認しない」の行と、「Places needing care」の節を足す。
  - init の SKILL.md：既存の CLAUDE.md に、「Common commands」と「Places needing care」も、足りなければ追記する。
  - ship の SKILL.md：要注意の場所の参照先を「Places needing care」の節とする。
  - ask の SKILL.md：人間しか起動できないコマンドは、コマンドと引数を分けて示し、「コマンドを自分で打ってから引数を貼る」と案内する。
  - guide.md の §0・§1・§2-A・§2-D・§5 を、上の変更に合わせる（160 行以下を守る）。
  - README.md・README.ja.md に、クラウドで使う方法を足し、Notes を直す。
  - ADR 0013 を起票する。plugin.json を 0.6.0 にし、CHANGELOG.md に追記する。
- やらないこと（Non-goals）:
  - `~/.claude/CLAUDE.md`（ユーザーのグローバルな指示）の変更。リポジトリの外にあり、別途ユーザーが判断する。
  - kome-oroshi-app の CLAUDE.md への反映。init は既存の節の中には行を足さないので、手で足す（このデザインの完了後に、kome 側で行う）。
  - 前回の一覧の A2（init の言語の判定）、A5（承認済みの design doc の改訂の手順）、A7（他の SDD ツールからの移行）、A8（ask で HEAD を表示）、A9（文書だけの差分で /simplify を省く）。
  - スキル・エージェントの追加と削除（数は 6 のまま）。

## 3. 要件
- REQ-1: adr の SKILL.md のステップ 4 が、次のとおりであること。
  - 承認済みの design doc か Plan Mode の計画のタスクとして記録するときは、確認せずに `docs/adr/NNNN-<slug>.md` に保存し、パスを報告して次のタスクへ進む。中身は PR で確認される。
  - それ以外のとき（単独の 2-B、実装中に新しく出た判断、既存の ADR を Superseded にするとき）は、今までどおり案を見せ、承認を得てから保存する。
- REQ-2: CLAUDE.md のテンプレートの「Development flow」に、次の趣旨の行があること。「design doc か計画が承認されたら、タスクの間で確認せずに最後まで進める。止まるのは、計画からはずれたとき、Accepted な ADR とぶつかったとき、人間にしかできない確認があるとき、コミット・PR のときだけ。追加の作業を持ちかけたり、答えた問いをもう一度聞いたりしない。」
- REQ-3: CLAUDE.md のテンプレートに、「Places needing care」の節があること。プレースホルダーには、`/sdd:ship` がこの節に挙げた場所に触れた差分の区分を上げることを書く。
- REQ-4: init の SKILL.md のステップ 2 が、既存の CLAUDE.md に、「Common commands」「Development flow」「Design decisions」「Places needing care」の節（または同じ役割の節）のうち、足りないものを追記する案を作ること。Common commands は、リポジトリから分かるコマンド（package.json の scripts など）で埋めること。
- REQ-5: ship の SKILL.md のステップ 0 が、要注意の場所を「CLAUDE.md の『Places needing care』の節（または同じ役割の節）に挙げた場所」と書いていること。判定の規則は、それ以外変えないこと。
- REQ-6: ask の SKILL.md のステップ 4 が、人間しか起動できないコマンドを案内するときに、コマンド（例 `/sdd:design`）と引数を別々のコードブロックで示すこと。また、「コマンドを自分で打ってから引数を貼る。全体を貼ると起動しない」と添えること。
- REQ-7: guide.md が上の変更と矛盾せず、160 行以下であること。
  - §0：Common commands の確認が init の案に含まれること。
  - §1：要注意の場所が「Places needing care」であること。
  - §2-A の 6：計画の中の ADR のタスクは確認なしで保存され、PR で確認すること。
  - §2-D：承認したあとはタスクの間で止まらないこと。
  - §5：人間しか起動できないコマンドの打ち方。
- REQ-8: README.md と README.ja.md に、次のことが同じ内容で書かれていること。
  - クラウドで使う方法：claude.ai で sdd-lite のマーケットプレイスからプラグインを追加すると、`sdd@synced` として手元とクラウドの両方で読み込まれる。リポジトリの `.claude/settings.json` の `enabledPlugins` では、クラウドに入らない。
  - 手元で `sdd@sdd-lite` と `sdd@synced` が二重に読み込まれたときの止め方。
  - Notes の ADR の保存（確認なしで保存される場合）。
  - 人間しか起動できないコマンドの打ち方。
  - 書く前に、公式ドキュメント（plugins の loading・cloud-environments）で、今も事実であることを確かめる。
- REQ-9: ADR 0013 が Accepted で、決定と、不採用の代替案とその理由が書かれていること。
- REQ-10: plugin.json の version が 0.6.0 で、CHANGELOG.md に 0.6.0 が書かれていること。変更したスキルの `reviewed` が実施日であること。
- 非機能要件:
  - 予算：スキル＋エージェントは 6 のまま。guide.md は 160 行以下。`bash .github/scripts/check-principles.sh` が 0 で終わること。
  - 検証：`claude plugin validate --strict .` と `bash .github/scripts/check-public-files.sh` が通ること。ADR 0010 の検証方法（`..` を含むパスやシェル展開が無い、など）も通ること。
  - 互換性：`- Status:` の行、REQ-n、`- [ ]` の Tn の形は変えず、ask・ship・verifier の判定を変えないこと。

## 4. 設計
- 全体方針：承認を求める場所を、ADR 0009 の 2 回（設計と PR）に寄せる。「承認したあとは止まらない」をテンプレートとして各プロジェクトの CLAUDE.md に入れる。こうすると、スキルの外（タスクの実装中）でも効く。
- adr：承認済みの計画に入っている ADR は、計画を承認した時点で「記録する」ことが決まっている。中身は PR の差分で確認できるので、保存の前の承認を省く。計画に無い判断と Superseded は、決定そのものが新しいので、今までどおり承認を得る。
- Places needing care：節の名前を決めておけば、ship が参照する場所がはっきりする。init の追記の対象にもなる。テンプレートは英語で書き、見出しは各言語に訳してよい（ADR 0010。ship は「同じ役割の節」も見る）。
- 純正で代替できない理由：スキルの追加は無い。変更はすべて既存のスキル・テンプレート・文書の中で行う。
- 検討した代替案と不採用の理由（ADR 0013 に記録する）：
  - adr の承認をすべて無くす：2-B の単独の ADR は「設計の承認」に当たるので、無くすと設計の承認が 0 回になる。
  - CLAUDE.md のテンプレートには書かず、guide だけに書く：guide は ask のときしか読まれない。実装中のモデルの癖（確認を求める）には効かない。
  - フックや設定（auto mode など）で止まらないようにする：権限の確認と承認の問いかけは別のものである。また、純正の設定をユーザーに強いることになる。

## 5. 実装タスク
- [x] T0: この計画を docs/design/2026-11-trial-feedback.md として保存し、Status を Approved にし、このタスクにチェックを付ける（作業ブランチ `feat/trial-feedback` を切ってから）
- [x] T1: `/sdd:adr` の手順で ADR 0013「承認済みの計画の中では確認を求めない」を起票する。計画のタスクなので、確認せずに保存する（対応要件：REQ-9）
- [x] T2: CLAUDE.md のテンプレートと init の SKILL.md を直す（REQ-2〜REQ-4）
- [x] T3: adr・ship・ask の SKILL.md を直し、`reviewed` を更新する（REQ-1、REQ-5、REQ-6、REQ-10）
- [x] T4: guide.md を直し、160 行以下に収める（REQ-7）
- [x] T5: 公式ドキュメントで確かめてから、README.md と README.ja.md を直す（REQ-8）
- [x] T6: plugin.json を 0.6.0 にし、CHANGELOG.md に追記する（REQ-10）
- [x] T7: 一時的な git リポジトリで、`claude -p --plugin-dir ./plugins/sdd` を使って E2E を行う（REQ-1、REQ-4、REQ-6）。結果を §6 に記録する。
  - ①既存の CLAUDE.md（Common commands が無く、package.json がある）に `/sdd:init` を実行し、案に Common commands（scripts から埋めたもの）と Places needing care が入ることを確かめる。
  - ②承認済みの計画のタスクとして `/sdd:adr` を実行させ、確認を求めずに保存されることを確かめる。単独で実行したときは案を見せて止まることも確かめる。
  - ③区分 A になる依頼で `/sdd:ask` を実行し、`/sdd:design` と引数が別々に示され、打ち方の注意が添えられることを確かめる。

## 6. テストと検証
- 機械的な確認：`claude plugin validate --strict .`、`bash .github/scripts/check-public-files.sh`、`bash .github/scripts/check-principles.sh` がすべて通ること。`wc -l plugins/sdd/skills/ask/guide.md` が 160 以下であること。
- 文言の確認：`grep -n 'Places needing care' plugins/sdd/skills/{init,ship}/* plugins/sdd/skills/ask/guide.md` が init のテンプレート・ship・guide にあること。README.md と README.ja.md の節が対応していること。
- E2E：T7 の①〜③。
- 照合：`/sdd:ship` の sdd:verifier で、REQ-1〜REQ-10 を照合する。
- 公式ドキュメントの確認（2026-11-02、T5）:
  - Plugin loading reference（code.claude.com/docs/en/plugins/loading）：claude.ai のアカウントで有効にしたプラグインは `<name>@synced` として、Cowork と、claude.ai のアカウントでサインインしたターミナルで読み込まれる。`"<name>@synced": false` で止められる。同じ名前の別の出どころのプラグインが有効なら、synced の方は読み込まれない。クラウドのセッション（claude.ai/code）については書かれていない。
  - Configure cloud environments（code.claude.com/docs/en/cloud-environments）：リポジトリの `.claude/settings.json` の `enabledPlugins` と、ユーザー設定だけのプラグインは、クラウドのセッションに入らない。
  - クラウドで `sdd@synced` が読み込まれることは、kome-oroshi-app の試験運転（2026-11-02）で実際に確かめた。README にはそのとおりに書いた。
- `/simplify` の反映（2026-11-02）：修正の深さの指摘を受けて、承認後に止まらない決まりと、ADR のタスクに「確認なしで保存する」と書くことを、design の SKILL.md にも持たせた（§2 のやることに無かった変更）。これで、既存の CLAUDE.md の利用者でも区分 A の流れで効く。
- `/code-review` の反映（2026-11-03）：README の重複の止め方をユーザー設定か `.claude/settings.local.json` に直した（コミットする設定に書くと協力者の sdd が止まる）。adr は「承認済みの計画のタスクが、その判断を ADR として記録すると書いているか」で判断するようにし、design に書かせていた英語の目印は取りやめた。テンプレートの Places needing care のプレースホルダーに "none" を許し、init にその埋め方を書いた。guide の「rule 7」という番号での参照をやめた。ask は `/sdd:ship` に例の引数を付けないようにした。見送り：init が既存の「Development flow」の中に行を足すこと（Non-goal のまま）、`.claude/worktrees/` の扱い（コミットに含めない）。
- 結果（2026-11-02、T7。一時的な git リポジトリで `claude -p --plugin-dir ./plugins/sdd` を実行）:
  - ①init：既存の CLAUDE.md（英語、Common commands 無し）に対し、package.json の scripts で埋めた Common commands、7 行目を含む Development flow、Design decisions、Places needing care を追記する案を出し、承認を求めて止まった。既存の言語の行があるため、言語の行は足さなかった。追加で、パッケージマネージャ（npm でよいか）と Places needing care に書くパスも聞いた。セットアップの 1 回の承認の中なので、許容とする。
  - ②adr：承認済みの design doc の T1 として実行すると、確認を求めずに `docs/adr/0002-use-plain-functions.md` に保存し、「事前の承認は取らずに保存した。PR でレビューされる」と報告した。単独で `/sdd:adr <題>` を実行すると、案を見せて「この内容で保存してよいですか？」で止まり、保存しなかった。
  - ③ask：区分 A の依頼で、`/sdd:design` と引数を別々のコードブロックで示した。「行全体を貼り付けても起動しないので、まずコマンドを入力し、そのあと引数を貼り付ける」と添えた。§2-A の 6 の「ADR は確認なしで保存し、PR でレビューする」も案内した。

## 7. 未解決の点
- なし
