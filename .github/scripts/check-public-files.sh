#!/usr/bin/env bash
# Checks the tracked files for personal information and invisible Unicode characters.
# Run from the repository root: bash .github/scripts/check-public-files.sh
set -euo pipefail

status=0

# Email addresses other than GitHub noreply addresses, and absolute paths under /home.
emails=$(git grep -hoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}' -- . \
  | grep -vE '@users\.noreply\.github\.com$|^noreply@github\.com$' || true)
if [ -n "$emails" ]; then
  echo "Found email addresses other than GitHub noreply addresses:"
  git grep -nE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}' -- . \
    | grep -vE '@users\.noreply\.github\.com|noreply@github\.com' || true
  status=1
fi
if git grep -nE '/home/[a-z]' -- .; then
  echo "Found absolute paths under /home."
  status=1
fi

# Bidirectional control characters and zero-width characters, which can hide text from reviewers.
if git grep -nP '[\x{200B}-\x{200F}\x{202A}-\x{202E}\x{2060}-\x{2064}\x{2066}-\x{2069}\x{FEFF}]' -- .; then
  echo "Found invisible Unicode characters (bidi controls or zero-width characters)."
  status=1
fi

exit "$status"
