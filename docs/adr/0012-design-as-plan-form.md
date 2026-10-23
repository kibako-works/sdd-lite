# 0012. /sdd:design は計画の書式と保存だけを受け持ち、質問・計画・承認は Plan Mode に任せる

- Status: Accepted
- 日付: 2026-10-23
- 関連: docs/design/2026-10-shrink-design.md、docs/adr/0009-design-principles.md、docs/adr/0011-lighter-default-and-ship-categories.md

## Context（背景）
- `/sdd:design` は、Plan Mode の中で「1 問ずつ質問する → テンプレートで計画をまとめる → 承認を求める → 保存する」をすべて自分の手順として持っていた。質問・計画・承認は、純正の Plan Mode の機能と重なる（ADR 0009 の原則 2）。
- 公式の設定 `plansDirectory` で、Plan Mode の計画をリポジトリ内に保存できる。パスはプロジェクトのルートからの相対で、既定は `~/.claude/plans`。CLAUDE.md で書式を指定すると、計画はそれに従う。ただし次の問題がある（v2.1.308 で確認）。
  - ファイル名にランダムな語尾が付き、ファイル名を決める設定は無い。
  - 承認しても Status は変わらない。`/sdd:ask` と `/sdd:ship` は `- Status: Approved` で現在地と区分を判定している。
  - 全部の計画に効くので、区分 B・C の小さな計画も同じディレクトリに溜まる。
- 承認のときに「clear context」を選ぶと、会話（スキルの指示を含む）は消え、計画だけが残る。
- フックの PostToolUse(ExitPlanMode) には、計画ファイルのパスと本文が渡される。

## Decision（決定）
- 質問・計画・承認は Plan Mode に任せること。`/sdd:design` は、次のことだけを受け持つこと。
  - 計画の最初に、デザインドキュメントの書式（テンプレート）を渡す。
  - 承認後に、計画ファイルを `docs/design/YYYY-MM-<slug>.md` に写し、Status を Approved にする。
- 保存の指示は、テンプレートの実装タスクの先頭に T0 として置くこと。保存先の具体的なパスは、計画を書くときに T0 に書くこと。承認されたら、最初に T0 を実行すること。
- 計画ファイルは写すだけで消さないこと。`plansDirectory` は設定しないこと。
- 保存されるデザインドキュメントの形（Status・REQ-n・`- [ ]` の Tn）は変えないこと。
- design の retire-when を「純正の Plan Mode が、承認した計画を決めたファイル名でリポジトリに保存し、承認済みの印を付けられるようになったら削除」にすること。

## Consequences（結果）
- `/sdd:design` の手順が減る。質問の仕方や承認の画面は、純正の Plan Mode の改善がそのまま効く。
- 書式は計画の前に渡すので、承認した中身と保存した中身は一致する。保存先のファイル名も承認の前に確かめられる。
- clear context を選んでも、T0 が計画に残るので保存が漏れにくい。ただし T0 の実行は Claude が計画を上から実行するかに頼る。
- 保存したデザインドキュメントに、実行済みの T0 が残る。`- [x]` なので、ask の未完了のタスクの数には入らない。
- 小さな計画はリポジトリに溜まらない。計画ファイルは `~/.claude/plans` に残る。
- スキルの数（6）は変わらない。
- 不採用にした代替案:
  - 廃止し、init が `plansDirectory: docs/design` と CLAUDE.md の規則を書く: スキルは 1 つ減るが、小さな計画も docs/design/ にランダムな名前で溜まる。改名と Status の更新は、Claude が規則を守るかに頼る。
  - 廃止し、`plansDirectory` は既定のまま、CLAUDE.md の規則で写す: 計画は溜まらないが、確実さは上と同じく規則頼みになる。書式を CLAUDE.md に置くと、どのプロジェクトでも毎回のセッションでトークンを使う。
  - PostToolUse(ExitPlanMode) のフックで自動で写す: 機械的で確実だが、スクリプトの保守が増える。日本語の題からの slug 作り・Windows 対応・予算の扱いを新しく決める必要がある。
  - 計画は自由な形で作り、承認後に書式へ整える: 承認した中身と保存した中身がずれる。

## 検証方法（任意）
- `grep -n 'T0' plugins/sdd/skills/design/template.md` の結果が 1 件以上であること。
- `grep -c plansDirectory plugins/sdd/skills/init/SKILL.md plugins/sdd/skills/init/claude-md-template.md` の結果が、どちらも 0 であること。
- `bash .github/scripts/check-principles.sh` が 0 で終わること。
