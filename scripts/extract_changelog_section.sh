#!/usr/bin/env bash
# Extracts the CHANGELOG.md section for a given release version (e.g. "2.4.1"):
# the category header + bullets between its "## [vX.Y.Z](...)" heading and the
# next heading, with the heading itself and the trailing "---" separator
# stripped. This is exactly what goes into the GitHub Release body.
#
# Usage: extract_changelog_section.sh <version> [changelog-file]

set -euo pipefail

VERSION="${1:?usage: extract_changelog_section.sh <version> [changelog-file]}"
CHANGELOG="${2:-CHANGELOG.md}"

awk -v ver="$VERSION" '
  BEGIN { in_section = 0; found = 0; n = 0 }
  /^## \[v[0-9]/ {
    if (in_section) { exit }
    if (index($0, "[v" ver "]") > 0) { in_section = 1; found = 1; next }
    next
  }
  in_section { n++; buf[n] = $0 }
  END {
    if (!found) { exit 1 }
    # trim trailing blank lines and a trailing "---" separator line
    while (n > 0 && (buf[n] ~ /^[[:space:]]*$/ || buf[n] ~ /^---+[[:space:]]*$/)) { n-- }
    # trim leading blank lines
    start = 1
    while (start <= n && buf[start] ~ /^[[:space:]]*$/) { start++ }
    for (i = start; i <= n; i++) { print buf[i] }
  }
' "$CHANGELOG"
