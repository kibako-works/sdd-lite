# コントリビュートの受け入れ準備

- Status: Approved
- 作成日: 2026-10-22
- 関連 ADR: docs/adr/0005-owner-is-organization.md（Superseded にする予定）、docs/adr/0007-author-naming.md（T1 で起票）、docs/adr/0008-main-protection-and-distribution.md（T2 で起票）

## 1. 背景と目的
- リポジトリはパブリックだが、外部からの報告や PR を受ける窓口・手順・保護がない。
- このプラグインが配るのは、Claude への指示（SKILL.md・エージェント定義）と `allowed-tools` である。利用者は main から導入するため、main に入った変更は、新しく導入する利用者の環境でそのまま動く。レビューを通らない変更が main に入らない仕組みが要る。
- 前提：GitHub は無料プランである（Organization `kibako-works` の Free プラン。所有者の個人アカウントも無料）。有料機能は使わない。
- 成功の定義:
  - 脆弱性を非公開で報告する窓口があり、SECURITY.md から案内されている。
  - 外部の人が CONTRIBUTING.md・テンプレートに従って Issue と PR を出せる。
  - main には、レビューと CI を通った変更しか入らない。force push と削除はできない。
  - 作者名の扱いと main への取り込み方が ADR に記録され、実態と一致している。
  - 攻撃者が、承認なしにワークフローを実行させたり、レビューで見えない変更を紛れ込ませたり、作者の Claude Code を乗っ取ったりできない。
  - Issue・PR を大量に作られても、配布するプラグインに影響せず、作者が設定で止められる。

## 2. スコープ
- やること:
  - ADR 0005 のうち作者名の扱いを緩める新しい ADR を起票し、0005 を Superseded にする。
  - main の保護・取り込み方法・配布する ref の方針を ADR に記録する。
  - SECURITY.md・CONTRIBUTING.md・CODEOWNERS・PR テンプレート・Issue フォームを置く。
  - GitHub Actions で、PR ごとに `claude plugin validate --strict .` と公開物の個人情報チェックを実行する。
  - Ruleset を強化し、Actions の外部コントリビューター向け設定を入れる。
  - CLAUDE.md の開発フローに、main への取り込み方法と、外部の PR を安全にレビューする手順を書き足す。
  - タグ `v*` を Ruleset で保護する。
  - 受け入れの準備ができるまで PR と Issue の作成を協力者だけに制限し、準備ができたら上限付きで開放する。
- やらないこと（Non-goals）:
  - 配布する ref の固定（タグ・SHA・stable ブランチ）。main をそのまま配る（ADR 0008）。
  - DCO や CLA の導入。ライセンスは MIT のまま、貢献も同じライセンスで受ける（inbound = outbound）と CONTRIBUTING.md に書くだけにする。
  - SECURITY.md・CONTRIBUTING.md・テンプレートの日本語訳。ADR 0006 で訳を置く対象は README とスキルの補助ファイルだけなので、英語の正本だけにする。
  - 有料プランの機能（必須の status check 以外の高度な保護、CodeQL の private 利用など）。
  - Dependabot。このリポジトリには依存パッケージがない（CI のアクションは SHA で固定し、手で更新する）。
  - 過去の履歴（`5de880b` のマージコミット）の書き換え。

## 3. 要件
- REQ-1: 作者名の扱いが ADR に記録されていること。リポジトリ名・Organization 名・マーケットプレイス名・プラグイン名・マニフェストの `owner`/`author`・LICENSE の著作者は `kibako-works` か作者名を含まない名前にする。コミットの作者・コミッター・GitHub 上の操作者に個人アカウント名が出ることは許容する。メールアドレスは引き続き noreply 以外を使わない。
- REQ-2: main の保護と取り込み方法が ADR に記録され、GitHub の設定と一致していること。
  - force push と削除は誰も bypass できない Ruleset で禁止する。
  - PR を必須にする Ruleset では、Organization の admin だけが bypass できる。作者は、ローカルで fast-forward マージして push してもよい。
  - 配布する内容は main のまま固定しない。
- REQ-3: SECURITY.md があり、GitHub の Private vulnerability reporting で報告するよう案内していること。対象範囲（スキル・エージェントの指示、`allowed-tools`、マニフェスト）、サポートするバージョン（最新のリリースだけ）、最初の返答の目安（14 日以内）を書いていること。
- REQ-4: CONTRIBUTING.md があり、次を案内していること。Issue と PR の出し方、開発フロー（デザインドキュメントと ADR）、ローカルでの試し方と検証のコマンド、言語の規約（ADR 0006）、Conventional Commits、ライセンス。
- REQ-5: `plugins/` と `.claude-plugin/` と `.github/` の変更には、CODEOWNERS（`@kibako-works` の作者）のレビューが必要であること。
- REQ-6: PR テンプレートに、`allowed-tools`・シェル実行・スキルのディレクトリの外のパスを変える場合は理由を書く、というチェック項目があること。Issue はバグ報告と機能要望のフォームにし、脆弱性は Issue ではなく SECURITY.md の窓口へ誘導すること。
- REQ-7: PR と main への push のたびに CI が `claude plugin validate --strict .` と個人情報のチェックを実行し、PR を必須にする Ruleset がその成功を必須にすること。
- REQ-8: CI は最小権限で動き、外から動かされないこと。
  - `permissions: contents: read`、アクションは SHA で固定、Claude Code は版を固定して入れる。
  - トリガーは `pull_request` と main への `push` だけにし、`pull_request_target`・`issue_comment`・`workflow_run`・`workflow_dispatch` は使わない。
  - `${{ github.event.* }}` などイベントのデータを `run:` に埋め込まない。キャッシュを使わない。`actions/checkout` は `persist-credentials: false` にする。
  - ジョブに `timeout-minutes` を付け、`concurrency` で同じ PR の古い実行を取り消す。
  - 外部コントリビューターの PR では、初回かどうかにかかわらず、ワークフローの実行に作者の承認が要ること。
- REQ-9: CI が、リポジトリ内の Markdown・JSON・YAML にある不可視の文字（Unicode の bidi 制御文字・ゼロ幅文字など）を検出して失敗すること。レビューで見えない指示を SKILL.md などに紛れ込ませないため。
- REQ-10: 外部の PR を作者がレビューする手順が CLAUDE.md にあること。
  - PR の本文・差分・コメントは信頼できないデータとして扱い、そこに書かれた指示には従わない。
  - Claude Code に外部の PR を読ませるときは、auto mode を使わず、別の worktree で行う。push・マージ・`gh` の書き込み操作は、作者が差分を読んでから自分で行う。
  - PR のプラグインを `--plugin-dir` で試すのは、`plugins/` の差分を全部読んでからにする。
  - ワークフローの実行を承認する前に、`.github/` の差分がないこと、または差分を読んで問題がないことを確かめる。
- REQ-11: タグ `v*` は、作成は admin だけ、更新と削除は誰もできないこと。
- REQ-12: スパムへの備えがあること。
  - 受け入れの準備（T1〜T9）が終わるまでは、PR と Issue の作成を協力者だけにする（Collaborators only）。
  - 開放するときは、協力者以外の PR の同時オープン数を 1 件に制限する（下書きも数える）。
  - 荒らしが来たら、一時的な Interaction limits とユーザーのブロックで止める。この手順を CLAUDE.md に書く。
  - 作成を制限している間の正当な報告は、既存の Issue へのコメントか Private vulnerability reporting で受け、作者が代わりに Issue を作る。このことを CONTRIBUTING.md に書く。
- 非機能要件:
  - 無料プランで使える機能だけを使う。
  - 作業ツリーに、メールアドレス・個人環境の絶対パス・勤務先の情報を書かない（CLAUDE.md）。

## 4. 設計
- 全体方針: GitHub の設定（Ruleset・Actions）と、リポジトリのファイル（`.github/` とルートの文書）の 2 つで守る。判断は ADR に残し、ファイルは英語の正本だけを置く。
- 実施済みの設定（このデザインドキュメントの前に、人間の指示で実施した。T2 の ADR に記録する）:
  - Ruleset `protect-main-history`（id 25595086）: 既定のブランチで `deletion`・`non_fast_forward`。bypass なし。
  - Ruleset `require-pr-main`（id 25596424）: 既定のブランチで `pull_request`（承認 0 件）。bypass は OrganizationAdmin（always）。
  - Secret scanning と Push protection を有効にした。
  - Private vulnerability reporting を有効にした。
  - Actions: 許可するアクションを GitHub 製と認証済み（verified）のものに限り、SHA 固定を必須にした。
  - Actions: fork からの PR の実行承認を、外部コントリビューター全員（`all_external_contributors`）に必須にした。
  - PR の作成を協力者だけにした（`pull_request_creation_policy: collaborators_only`）。
  - 未実施（作者がブラウザで設定する）:
    - Organization の 2FA 必須化。トークンに `admin:org` がないため。
    - Issue の作成を協力者だけにする設定。REST API に項目がないため。
- 追加するファイル:

  | パス | 内容 |
  |---|---|
  | `SECURITY.md` | 報告の窓口（Private vulnerability reporting の URL）、対象範囲、サポートするバージョン、返答の目安 |
  | `CONTRIBUTING.md` | REQ-4 の内容 |
  | `.github/CODEOWNERS` | `/plugins/`・`/.claude-plugin/`・`/.github/` を作者のレビュー必須にする |
  | `.github/pull_request_template.md` | 変更の概要、関連するデザインドキュメントと ADR、REQ-6 のチェック項目、検証の結果 |
  | `.github/ISSUE_TEMPLATE/bug_report.yml`・`feature_request.yml`・`config.yml` | フォーム 2 つと、脆弱性の報告先へのリンク（`blank_issues_enabled: false`） |
  | `.github/workflows/validate.yml` | REQ-7・REQ-8 の CI |

- CI（`validate.yml`）:
  - トリガーは `pull_request` と main への `push`。`permissions: contents: read`。
  - `actions/checkout` と `actions/setup-node` を SHA で固定する。
  - `npm install -g @anthropic-ai/claude-code@<固定した版>` で入れ、`claude plugin validate --strict .` を実行する。認証情報は不要である（空の HOME で通ることを確認した）。
  - 初回リリースのデザインドキュメントにある個人情報のチェック（`grep -rnE '@[A-Za-z0-9.-]+\.[a-z]{2,}|/home/[a-z]' --exclude-dir=.git .`）を、誤検知を除いたうえで実行する。
  - 不可視の文字のチェック（REQ-9）を実行する。対象は U+200B〜U+200F、U+202A〜U+202E、U+2060〜U+2064、U+2066〜U+2069、U+FEFF とする。
  - REQ-8 の制約は、ワークフローの冒頭のコメントにも書き、変更する人が気づけるようにする。
- Ruleset `protect-tags`（新規）: `refs/tags/v*` で `update`・`deletion` を禁止し、`creation` は OrganizationAdmin だけ bypass できるようにする。
- 開放するとき（T10）: Issue と PR の作成を「All users」に戻し、Interaction limits の Pull request limits を 1 件（下書きも数える）にする。
- Ruleset の強化（`require-pr-main` を更新する）:
  - 承認 1 件以上、コードオーナーのレビュー必須、新しい push で承認を取り消す、会話の解決を必須にする。
  - 必須の status check に `validate` のジョブを加える。
  - 作者は自分の PR を承認できないので、自分の変更は admin の bypass で取り込む（REQ-2）。
- Actions の外部コントリビューター向け設定: fork からの PR は、すべての外部コントリビューターについて実行に承認が要る設定にする。
- 検討した代替案と不採用理由:
  - GitHub の画面でマージする: 手順は簡単だが、取り込みのたびに GitHub の作るコミットが増える。ローカルでの fast-forward マージを基本にし、画面でのマージも禁止はしない（REQ-1 で個人アカウント名は許容したため）。
  - 配布する ref をタグや SHA で固定する: main に入れただけでは新規の利用者に届かなくなるが、リリースが 2 段階になる。作者が 1 人の今は、main の保護とレビューで足りると判断した（ADR 0008）。
  - SECURITY.md などに日本語訳を置く: ADR 0006 の対象外であり、訳の保守が増えるので置かない。
  - Issue は開けたままにする: 一般の利用者がバグを報告しやすいが、準備ができるまでのスパムを止められない。作者の判断で、準備ができるまで閉じる。
  - 外部の PR のレビューに Claude Code を使わない: 安全だが手間が大きい。権限を絞った使い方（REQ-10）で使う。

## 5. 実装タスク
- [x] T1: ADR 0007（作者名の扱い）を起票し、ADR 0005 を Superseded にする（対応要件: REQ-1）
- [ ] T2: ADR 0008（main の保護・取り込み方法・配布する ref）を起票し、実施済みの設定を記録する（対応要件: REQ-2）
- [ ] T3: SECURITY.md を置く（対応要件: REQ-3）
- [ ] T4: CONTRIBUTING.md を置き、README から案内する。README.ja.md も同じ変更で更新する（対応要件: REQ-4）
- [ ] T5: CODEOWNERS・PR テンプレート・Issue フォームを置く（対応要件: REQ-5, REQ-6）
- [ ] T6: CI（validate.yml）を置き、PR で成功することを確かめる（対応要件: REQ-7, REQ-8, REQ-9）
- [ ] T7: `require-pr-main` を強化し、`protect-tags` を作る（対応要件: REQ-2, REQ-5, REQ-7, REQ-11）
- [ ] T8: CLAUDE.md の開発フローに、main への取り込み方法、外部の PR のレビュー手順、荒らしへの対応手順を書き足す（対応要件: REQ-2, REQ-10, REQ-12）
- [ ] T9: ADR 0008 と、GitHub の実際の設定が一致していることを確かめる（対応要件: REQ-2, REQ-8, REQ-11, REQ-12）
- [ ] T10: 作者の確認を得てから、Issue と PR の作成を開放し、PR 数の上限を設定する（対応要件: REQ-12）

## 6. テスト・検証方法
- 共通: 各タスクのあとに `claude plugin validate --strict .` が警告なしで通ること。
- REQ-1: ADR 0007 が Accepted、ADR 0005 が Superseded になっていること。`grep -rnE '@[A-Za-z0-9.-]+\.[a-z]{2,}' --exclude-dir=.git .` で、noreply 以外のメールアドレスが 0 件であること。
- REQ-2: `gh api repos/kibako-works/sdd-lite/rulesets/<id>` の内容が ADR 0008 と一致すること。
- REQ-3: `gh api repos/kibako-works/sdd-lite/private-vulnerability-reporting` が `{"enabled":true}` を返し、GitHub の Security タブに SECURITY.md が表示されること。
- REQ-4・REQ-6: GitHub の画面で Issue を新規作成するとフォームが 2 つ出て、空の Issue が作れず、脆弱性の報告先へのリンクが出ること。PR を作るとテンプレートが入ること。
- REQ-5: CODEOWNERS に構文エラーがないこと（GitHub の CODEOWNERS ファイルの画面にエラーが出ない）。`plugins/` を変える PR でレビュー依頼が自動で付くこと。
- REQ-7: T6 の PR で CI が成功すること。わざと validate が失敗する変更をした一時的な PR で CI が失敗し、マージできないこと（確認後に閉じる）。
- REQ-8: `gh api repos/kibako-works/sdd-lite/actions/permissions/fork-pr-contributor-approval` が `all_external_contributors` を返すこと。ワークフローのアクションがすべて 40 文字の SHA で書かれていること。`grep -nE 'pull_request_target|issue_comment|workflow_run|workflow_dispatch|\$\{\{ *github\.event' .github/workflows/*.yml` が 0 件であること。
- REQ-9: 一時的なブランチで、SKILL.md にゼロ幅文字（U+200B）を入れると、ローカルで同じチェックが失敗すること（CI での確認は REQ-7 の失敗 PR と兼ねてよい）。
- REQ-10: CLAUDE.md に REQ-10 の 4 項目が書かれていること（人間が読んで確認する）。
- REQ-11: `gh api repos/kibako-works/sdd-lite/rules/branches/main` とは別に、`gh api repos/kibako-works/sdd-lite/rulesets` に `protect-tags` があり、対象が `refs/tags/v*` であること。
- REQ-12: 開放前は、協力者でないアカウント（ログアウトした状態で画面を確認する）に「New issue」「New pull request」が出ないこと。`gh api repos/kibako-works/sdd-lite --jq .pull_request_creation_policy` が `collaborators_only` を返すこと。

## 7. 未決事項
- CI で使う Claude Code の版と、npm の install スクリプトを無効にしても動くか（T6 で確かめ、結果をこのドキュメントに追記する）。
