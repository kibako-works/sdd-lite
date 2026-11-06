#!/usr/bin/env bash
# Prints the CHANGELOG.md section of a version, or creates its GitHub Release from it (ADR 0015).
# Run from the repository root:
#   bash .github/scripts/release-notes.sh X.Y.Z           # print the notes only
#   bash .github/scripts/release-notes.sh --create X.Y.Z  # create the release vX.Y.Z
# --create needs the tag vX.Y.Z on GitHub already; it never creates a tag (--verify-tag).
# Only the topmost version in CHANGELOG.md is marked as the latest release.
set -euo pipefail

CHANGELOG=CHANGELOG.md

usage() {
  echo "Usage: bash .github/scripts/release-notes.sh [--create] X.Y.Z" >&2
  exit 2
}

create=0
if [ "${1:-}" = "--create" ]; then
  create=1
  shift
fi
[ "$#" -eq 1 ] || usage
version=$1
if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Not a version in the form X.Y.Z: $version" >&2
  exit 2
fi
if [ ! -f "$CHANGELOG" ]; then
  echo "$CHANGELOG not found. Run from the repository root." >&2
  exit 1
fi

# Prints the lines after "## [version]" up to the next "## [", without leading and trailing blank lines.
notes=$(awk -v heading="## [$version]" '
  index($0, "## [") == 1 { if (inside) exit; inside = (index($0, heading) == 1); next }
  inside {
    if ($0 ~ /^[[:space:]]*$/) { if (started) blanks++; next }
    while (blanks > 0) { print ""; blanks-- }
    print; started = 1
  }
' "$CHANGELOG")
if [ -z "$notes" ]; then
  echo "No notes for $version in $CHANGELOG." >&2
  exit 1
fi

if [ "$create" -eq 0 ]; then
  printf '%s\n' "$notes"
  exit 0
fi

topmost=$(sed -nE 's/^## \[([0-9]+\.[0-9]+\.[0-9]+)\].*/\1/p' "$CHANGELOG" | head -n 1)
if [ "$version" = "$topmost" ]; then
  latest=--latest
else
  latest=--latest=false
fi

printf '%s\n' "$notes" | gh release create "v$version" --verify-tag --title "v$version" --notes-file - "$latest"
