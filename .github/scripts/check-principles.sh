#!/usr/bin/env bash
# Checks the budgets in ADR 0009 and prints every violation.
# Usage: bash .github/scripts/check-principles.sh [repository root]
# Set CHECK_TODAY=YYYY-MM-DD to override today's date.
set -u

# Budgets (ADR 0009)
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

# Converts YYYY-MM-DD to UTC epoch seconds, with GNU or BSD date.
to_epoch() {
  if date -u -d @0 >/dev/null 2>&1; then
    date -u -d "$1" +%s 2>/dev/null
  else
    date -u -j -f '%Y-%m-%d' "$1" +%s 2>/dev/null
  fi
}

# Prints the lines between the first --- and the next ---.
frontmatter() {
  awk 'NR == 1 && $0 == "---" { inside = 1; next } inside && $0 == "---" { exit } inside { print }' "$1"
}

today_epoch=$(to_epoch "$TODAY")
if [ -z "$today_epoch" ]; then
  echo "NG: today's date is not a valid date: $TODAY"
  exit 1
fi

files=()
for f in "$ROOT"/plugins/sdd/skills/*/SKILL.md "$ROOT"/plugins/sdd/agents/*.md; do
  [ -f "$f" ] && files+=("$f")
done

# Also avoids expanding an empty array, which fails under set -u in bash 3.2 (macOS).
if [ "${#files[@]}" -eq 0 ]; then
  echo "NG: no skills or agents found under $ROOT/plugins/sdd"
  exit 1
fi

if [ "${#files[@]}" -gt "$MAX_COMPONENTS" ]; then
  fail "${#files[@]} skills and agents in total (limit $MAX_COMPONENTS)"
fi

if [ -f "$GUIDE" ]; then
  lines=$(wc -l <"$GUIDE" | tr -d ' ')
  if [ "$lines" -gt "$MAX_GUIDE_LINES" ]; then
    fail "${GUIDE#"$ROOT"/}: $lines lines (limit $MAX_GUIDE_LINES)"
  fi
fi

for f in "${files[@]}"; do
  name=${f#"$ROOT"/}
  fm=$(frontmatter "$f")
  if ! grep -qE '^[[:space:]]*retire-when:' <<<"$fm"; then
    fail "$name: no retire-when in the frontmatter"
  fi
  reviewed=$(sed -nE 's/^[[:space:]]*reviewed:[[:space:]]*["'\'']?([^"'\''[:space:]]+).*/\1/p' <<<"$fm" | head -n 1)
  if [ -z "$reviewed" ]; then
    fail "$name: no reviewed in the frontmatter"
    continue
  fi
  reviewed_epoch=$(to_epoch "$reviewed")
  if [ -z "$reviewed_epoch" ]; then
    fail "$name: reviewed is not a valid date: $reviewed"
    continue
  fi
  days=$(((today_epoch - reviewed_epoch) / 86400))
  if [ "$days" -gt "$MAX_REVIEWED_DAYS" ]; then
    fail "$name: reviewed $days days ago ($reviewed, limit $MAX_REVIEWED_DAYS days)"
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "Found $failures budget violation(s). See docs/adr/0009-design-principles.md."
  exit 1
fi
echo "OK"
