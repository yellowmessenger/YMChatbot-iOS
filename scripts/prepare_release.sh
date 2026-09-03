#!/usr/bin/env bash
# Prepares a release on the current feature/fix branch, following this repo's
# established convention: bump YMChat.podspec + both Info.plists, prepend a
# CHANGELOG.md entry, and create the two commits release PRs have historically
# carried ("Bump version to X.Y.Z" and "Add changelog entry for vX.Y.Z").
#
# This script does NOT tag or create a GitHub Release — per repo convention,
# tagging/release happens automatically once the PR merges to main (see
# .github/workflows/release.yml). Run this on your feature branch before
# opening the PR.
#
# Usage:
#   scripts/prepare_release.sh --bump <patch|minor|major> --category <category> "<bullet 1>" ["<bullet 2>" ...]
#   scripts/prepare_release.sh --version <X.Y.Z> --category <category> "<bullet 1>" ...
#
# --category accepts one of the established categories (or any custom text):
#   "New Update", "Bug Fix", "Security"
#
# Example:
#   scripts/prepare_release.sh --bump patch --category "Bug Fix" \
#     "Fixed the embedded WKWebView not resizing when the on-screen keyboard opens."

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PODSPEC="YMChat.podspec"
INFO_PLIST_MAIN="YMChat/Info.plist"
INFO_PLIST_TESTS="YMChatTests/Info.plist"
CHANGELOG="CHANGELOG.md"

BUMP=""
NEW_VERSION=""
CATEGORY=""
BULLETS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bump) BUMP="$2"; shift 2 ;;
    --version) NEW_VERSION="$2"; shift 2 ;;
    --category) CATEGORY="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) BULLETS+=("$1"); shift ;;
  esac
done

if [[ -z "$CATEGORY" || ${#BULLETS[@]} -eq 0 ]]; then
  echo "error: --category and at least one changelog bullet are required" >&2
  exit 1
fi

if [[ -n "$BUMP" && -n "$NEW_VERSION" ]]; then
  echo "error: pass either --bump or --version, not both" >&2
  exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$BRANCH" == "main" ]]; then
  echo "error: run this on a feature/fix branch, not main (matches repo convention: bump + changelog commits live on the PR branch)" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree is not clean; commit or stash your changes first" >&2
  exit 1
fi

CURRENT_VERSION="$(sed -n 's/.*spec\.version[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$PODSPEC")"
if [[ -z "$CURRENT_VERSION" ]]; then
  echo "error: could not read current version from $PODSPEC" >&2
  exit 1
fi

if [[ -n "$BUMP" ]]; then
  IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
  case "$BUMP" in
    major) NEW_VERSION="$((MAJOR + 1)).0.0" ;;
    minor) NEW_VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
    patch) NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
    *) echo "error: --bump must be patch, minor, or major" >&2; exit 1 ;;
  esac
elif [[ -z "$NEW_VERSION" ]]; then
  echo "error: pass --bump <patch|minor|major> or --version <X.Y.Z>" >&2
  exit 1
fi

if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: version must look like X.Y.Z, got: $NEW_VERSION" >&2
  exit 1
fi

if git rev-parse -q --verify "refs/tags/$NEW_VERSION" >/dev/null; then
  echo "error: tag $NEW_VERSION already exists" >&2
  exit 1
fi

case "$CATEGORY" in
  "New Update") CATEGORY_HEADING="New Update 🚀" ;;
  "Bug Fix") CATEGORY_HEADING="Bug Fix 🐛" ;;
  "Security") CATEGORY_HEADING="Security 🔒" ;;
  *) CATEGORY_HEADING="$CATEGORY" ;;
esac

echo "Bumping $CURRENT_VERSION -> $NEW_VERSION"

# --- 1. Bump version in podspec + both Info.plists, commit ---
sed -i.bak "s/spec\.version = \"$CURRENT_VERSION\"/spec.version = \"$NEW_VERSION\"/" "$PODSPEC" && rm -f "$PODSPEC.bak"
for plist in "$INFO_PLIST_MAIN" "$INFO_PLIST_TESTS"; do
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" "$plist" 2>/dev/null \
    || sed -i.bak "0,/<key>CFBundleShortVersionString<\/key>/{n;s/<string>[^<]*<\/string>/<string>$NEW_VERSION<\/string>/;}" "$plist" && rm -f "$plist.bak"
done

git add "$PODSPEC" "$INFO_PLIST_MAIN" "$INFO_PLIST_TESTS"
git commit -m "Bump version to $NEW_VERSION"

# --- 2. Prepend CHANGELOG entry, commit ---
TODAY="$(date +%Y-%m-%d)"
ENTRY_FILE="$(mktemp)"
{
  echo ""
  echo "## [v${NEW_VERSION}](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/${NEW_VERSION}) (${TODAY})"
  echo ""
  echo "#### ${CATEGORY_HEADING}"
  for b in "${BULLETS[@]}"; do
    echo "* ${b}"
  done
  echo ""
  echo "---"
} > "$ENTRY_FILE"

# Insert right after the "-----" divider that follows the CHANGELOG.md intro;
# the blank line that originally followed "-----" becomes the separator
# between our new "---" and the next (previously first) entry.
awk -v entryfile="$ENTRY_FILE" '
  { print }
  /^-----$/ && !inserted {
    while ((getline line < entryfile) > 0) print line
    inserted = 1
  }
' "$CHANGELOG" > "$CHANGELOG.new" && mv "$CHANGELOG.new" "$CHANGELOG"
rm -f "$ENTRY_FILE"

git add "$CHANGELOG"
git commit -m "Add changelog entry for v${NEW_VERSION}"

echo ""
echo "Done. Push this branch and open the PR as usual — merging to main will"
echo "automatically tag ${NEW_VERSION}, publish the GitHub Release, and push to CocoaPods trunk."
