#!/usr/bin/env bash
# ADR 0007 の予算を確かめる。違反があればすべて表示して 1 で終わる。
# 使い方: bash scripts/check-principles.sh [リポジトリのルート]
# 実行日は CHECK_TODAY=YYYY-MM-DD で差し替えられる。
set -u

# 予算（ADR 0007）
MAX_COMPONENTS=6
MAX_GUIDE_LINES=160
MAX_REVIEWED_DAYS=60

ROOT=${1:-.}
TODAY=${CHECK_TODAY:-$(date +%F)}
GUIDE="$ROOT/plugins/sdd/skills/ask/guide.md"

failures=0
fail() {
  echo "NG: $1"
  failures=$((failures + 1))
}

# YYYY-MM-DD を UTC のエポック秒にする（GNU と BSD の date の両方に対応）
to_epoch() {
  if date -u -d @0 >/dev/null 2>&1; then
    date -u -d "$1" +%s 2>/dev/null
  else
    date -u -j -f '%Y-%m-%d' "$1" +%s 2>/dev/null
  fi
}

# 最初の --- から次の --- までを出力する
frontmatter() {
  awk 'NR == 1 && $0 == "---" { inside = 1; next } inside && $0 == "---" { exit } inside { print }' "$1"
}

today_epoch=$(to_epoch "$TODAY")
if [ -z "$today_epoch" ]; then
  echo "NG: 実行日を日付として読めない: $TODAY"
  exit 1
fi

files=()
for f in "$ROOT"/plugins/sdd/skills/*/SKILL.md "$ROOT"/plugins/sdd/agents/*.md; do
  [ -f "$f" ] && files+=("$f")
done

if [ "${#files[@]}" -gt "$MAX_COMPONENTS" ]; then
  fail "スキルとエージェントの合計が ${#files[@]} 個（上限 $MAX_COMPONENTS）"
fi

if [ -f "$GUIDE" ]; then
  lines=$(wc -l <"$GUIDE" | tr -d ' ')
  if [ "$lines" -gt "$MAX_GUIDE_LINES" ]; then
    fail "${GUIDE#"$ROOT"/}: $lines 行（上限 $MAX_GUIDE_LINES 行）"
  fi
fi

for f in "${files[@]}"; do
  name=${f#"$ROOT"/}
  fm=$(frontmatter "$f")
  if ! grep -qE '^[[:space:]]*retire-when:' <<<"$fm"; then
    fail "$name: フロントマターに retire-when が無い"
  fi
  reviewed=$(sed -nE 's/^[[:space:]]*reviewed:[[:space:]]*([^[:space:]]+).*/\1/p' <<<"$fm" | head -n 1)
  if [ -z "$reviewed" ]; then
    fail "$name: フロントマターに reviewed が無い"
    continue
  fi
  reviewed_epoch=$(to_epoch "$reviewed")
  if [ -z "$reviewed_epoch" ]; then
    fail "$name: reviewed を日付として読めない: $reviewed"
    continue
  fi
  days=$(((today_epoch - reviewed_epoch) / 86400))
  if [ "$days" -gt "$MAX_REVIEWED_DAYS" ]; then
    fail "$name: reviewed が $days 日前（$reviewed、上限 $MAX_REVIEWED_DAYS 日）"
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "予算の違反が $failures 件ある（docs/adr/0007-design-principles.md）"
  exit 1
fi
echo "OK"
