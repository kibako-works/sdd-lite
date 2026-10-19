---
name: ask
description: 軽量 SDD（sdd プラグインのスキル・デザインドキュメント・ADR）の窓口。「/sdd:ask 〇〇したい」とやりたいことを書くか、引数なしで呼ぶと、今の状態と変更の規模から次に使う sdd のスキルと手順を案内する。軽量 SDD の進め方について、何から始めるか、次に何をするか、どのスキルを使うかを聞かれたときに使う。
argument-hint: [やりたいこと（省略時は今の状態から次の手順を案内）]
disable-model-invocation: false
metadata:
  kit: sdd
  reviewed: 2026-10-09
  retire-when: Claude Code 純正の機能が、スキル群の中から使うものを案内・振り分けるようになったら、または sdd の他のスキルがすべて外れたら削除する
---
対象: $ARGUMENTS

このスキルは案内だけを行う。スキルの実行とファイルの書き込みはしない。案内は guide.md に書かれた判断基準だけに基づいて行い、guide.md に無いもの（軽量 SDD の進め方に関係しない依頼を含む）は「sdd の範囲外」と伝えて終える。推測で他のツールやスキルを勧めない。

1. ${CLAUDE_SKILL_DIR}/guide.md を読む。
2. guide.md の「6. 現在地の判定」の表に必要な状態を読み取る。中身は読まず、有無と件数だけを、なるべくまとめて取る。
   - `ls -d CLAUDE.md docs/design docs/adr`
   - Approved のデザインドキュメント: `grep -l '^- Status: Approved' docs/design/*.md`。見つかったファイルごとに、未チェックのタスクの数を `grep -cF -- '- [ ]' <ファイル>` で数える。
   - git 管理下か: `git rev-parse --is-inside-work-tree`。管理外なら、以降の git のコマンドは使わない。
   - 未コミットの変更: `git status --porcelain`
   - デフォルトブランチに無いコミット: デフォルトブランチを `git symbolic-ref --short refs/remotes/origin/HEAD` で調べ（取れなければ `main` か `master` のうち存在するほう）、`git rev-list --count <デフォルトブランチ>..HEAD` で数える。今いるのがデフォルトブランチなら、上流にまだ push していないコミットを `git rev-list --count @{u}..HEAD` で数える。
   - これらで判断できなければ、推測せずに聞く。
3. guide.md の 6 節（表と「依頼文を使う」）で、現在地と次の手順を決める。
4. 質問したときは、答えを受けて手順 3 から判定し直す。決まったら、次の形で案内して終える。
   - 現在地と、そう判定した理由
   - 次に入力するコマンド（そのまま貼れる形。引数の例を含む）
   - その前にすること（例: Plan Mode に入る）
   - 人間しか起動できないコマンドなら、そのこと
   - その後の流れの概要
