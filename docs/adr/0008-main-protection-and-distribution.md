# 0008. main を Ruleset で守り、作者はローカルで取り込み、配布は main のまま固定しない

- Status: Accepted
- 日付: 2026-10-22
- 関連: docs/design/2026-10-contribution-readiness.md、docs/adr/0002-distribute-as-plugin.md、docs/adr/0007-author-naming.md

## Context（背景）
- このプラグインが配るのは、Claude への指示（SKILL.md・エージェント定義）と `allowed-tools` である。利用者は `kibako-works/sdd-lite` の既定のブランチ（main）から導入する。
- plugin.json に `version` を書いているので、導入済みの利用者には `version` が変わるまで更新が届かない。ただし新しく導入する利用者は、そのときの main を受け取る。つまり main に入った変更は、リリースしていなくても新規の利用者の環境で動く。
- リポジトリはパブリックで、GitHub は無料プランである。作者は 1 人で、自分の PR を自分で承認できない。
- 配布する ref を固定する方法は 2 つある。プラグインの source に `ref`・`sha` を書く方法と、利用者が `#<ref>` を付けて追加する方法である。固定すると、main に入れただけでは利用者に届かなくなる。その代わりリリースが 2 段階になるか、利用者に追加のし直しを求めることになる。
- 攻撃者は、fork からの PR でワークフローを書き換えて実行させたり、Issue・PR を大量に作ったりできる。

## Decision（決定）
- main を 2 つの Ruleset で守ること。
  - `protect-main-history`: force push（`non_fast_forward`）と削除（`deletion`）を禁止する。bypass できる人を置かない。
  - `require-pr-main`: PR を必須にする。承認 1 件以上、コードオーナーのレビュー、新しい push での承認の取り消し、最後の push をした人以外の承認（`require_last_push_approval`）、会話の解決、CI（validate）の成功を必須にする。GitHub の既定で有効な `require_extra_approval_for_unattributed_changes` もそのままにする。bypass できるのは OrganizationAdmin だけにする。
- コードオーナーは、個人アカウントではなく Organization のチーム `@kibako-works/maintainers` にすること（ADR 0007）。チームには作者を入れ、このリポジトリに Write 以上の権限を付ける。
- 外部の PR は、レビューして承認してから取り込むこと。作者自身の変更は、PR で CI を通したうえで、admin の bypass を使って、ローカルで fast-forward マージして push してよい。GitHub の画面でのマージも禁止しない（ADR 0007）。
- タグ `v*` を 2 つの Ruleset で守ること。bypass はその Ruleset のすべてのルールにかかるため、bypass の要らないルールと分ける。
  - `protect-tags`: 更新（`update`）と削除（`deletion`）を禁止する。bypass できる人を置かない。
  - `restrict-tag-creation`: 作成（`creation`）を禁止する。bypass できるのは OrganizationAdmin だけにする。
- 配布する内容は main のまま固定しないこと。marketplace.json のプラグインの source は相対パス（`./plugins/sdd`）のままにする。リリースのたびに `version` を上げる運用（ADR 0002）は変えない。
- GitHub Actions を次の設定にすること。
  - 使えるアクションは、GitHub 製と認証済み（verified）のものに限り、SHA での固定を必須にする。
  - fork からの PR では、外部のコントリビューター全員について、実行に作者の承認を必須にする。
  - GITHUB_TOKEN の既定の権限は read にし、Actions に PR の作成と承認を許可しない。
- Secret scanning・Push protection・Private vulnerability reporting を有効にしておくこと。
- 受け入れの準備ができるまでは、PR と Issue の作成を協力者だけにすること。開放するときは、書き込み権限のない人の PR の同時オープン数を、下書きも含めて 1 件に制限すること（Interaction limits の Pull request limits。期限はなく、変えるまで続く）。

## Consequences（結果）
- main の履歴の書き換えと削除は、作者を含めて誰にもできない。間違えたときは、revert のコミットで直す。
- 付けたタグは、作者を含めて誰にも付け替えたり消したりできない。間違えたときは、次のバージョンを出して直す。
- 外部の人の変更は、作者のレビューと CI を通らないと main に入らない。
- 作者は 1 人なので、自分の変更は bypass で入れることになり、第三者のレビューは受けない。CI と、デザインドキュメント・ADR の手順で補う。
- 作者のアカウントか `gh` のトークンが乗っ取られると、bypass で main に入れられてしまう。2FA と、外部の PR をレビューするときの手順（CLAUDE.md）で守る。
- main に入った変更は、すぐ新規の利用者に届く。レビューを通った変更だけが入ることを前提にする。
- 準備ができるまでは、協力者以外が Issue と PR を作れない。正当な報告は、既存の Issue へのコメントか Private vulnerability reporting で受ける。
- すべて無料プランで使える機能なので、費用はかからない。パブリックリポジトリでは標準ランナーの Actions も無料である。

## 検証方法（任意）
- `gh api repos/kibako-works/sdd-lite/rulesets --jq '.[].name'` に `protect-main-history`・`require-pr-main`・`protect-tags`・`restrict-tag-creation` があり、それぞれの内容（`gh api repos/kibako-works/sdd-lite/rulesets/<id>`）が Decision と一致すること。
- `gh api repos/kibako-works/sdd-lite/actions/permissions` が `"allowed_actions":"selected"` と `"sha_pinning_required":true` を返すこと。
- `gh api repos/kibako-works/sdd-lite/actions/permissions/fork-pr-contributor-approval` が `all_external_contributors` を返すこと。
- `gh api repos/kibako-works/sdd-lite --jq .security_and_analysis` で、`secret_scanning` と `secret_scanning_push_protection` が `enabled` であること。
- `jq -r '.plugins[].source' .claude-plugin/marketplace.json` が `./plugins/sdd` を返すこと。
