#!/usr/bin/env bash
#
# build.sh - Package CritKing for a CurseForge (manual) upload.
#
# The addon's files live at the repo root, so this stages them into a
# CritKing/ folder and zips that, producing a package that unpacks straight
# into Interface/AddOns:
#
#   CritKing-<version>.zip
#   └── CritKing/
#       ├── CritKing.toc
#       ├── CritKing.lua
#       └── sounds/
#
# Usage:
#   ./build.sh                 # version read from CritKing.toc
#   ./build.sh 1.0.2           # override the version string
#
set -euo pipefail

# --- Configuration ---------------------------------------------------------
PKG_NAME="CritKing"
MAIN_TOC="CritKing.toc"

# Files/dirs never included in the package (VCS, editor junk, repo-only docs,
# and the build output itself).
EXCLUDES=(
	".git"
	".github"
	".gitignore"
	".pkgmeta"
	".DS_Store"
	".AppleDouble"
	".LSOverride"
	"._*"
	"*.swp"
	"*.swo"
	"*~"
	".idea"
	".vscode"
	"build.sh"
	"CLAUDE.md"
	"DESCRIPTION.txt"
	"release"
)

# --- Setup -----------------------------------------------------------------
cd "$(dirname "$0")"
ROOT="$(pwd)"
RELEASE_DIR="$ROOT/release"

# Version: first CLI arg, else the "## Version:" line from the TOC.
if [[ $# -ge 1 ]]; then
	VERSION="$1"
else
	VERSION="$(grep -i '^## Version:' "$MAIN_TOC" | head -n1 | sed -E 's/^## Version:[[:space:]]*//' | tr -d '[:space:]')"
fi

if [[ -z "${VERSION:-}" ]]; then
	echo "error: could not determine version (no arg and none in $MAIN_TOC)" >&2
	exit 1
fi

STAGE="$RELEASE_DIR/stage"
ZIP_PATH="$RELEASE_DIR/${PKG_NAME}-${VERSION}.zip"

echo "==> Packaging $PKG_NAME $VERSION"

# --- Verify sources --------------------------------------------------------
if [[ ! -f "$ROOT/$MAIN_TOC" ]]; then
	echo "error: missing $MAIN_TOC" >&2
	exit 1
fi

# --- Stage -----------------------------------------------------------------
rm -rf "$STAGE"
rm -f "$ZIP_PATH"
mkdir -p "$STAGE/$PKG_NAME"

# Build rsync exclude flags.
RSYNC_EXCLUDES=()
for pat in "${EXCLUDES[@]}"; do
	RSYNC_EXCLUDES+=(--exclude "$pat")
done

echo "    + $PKG_NAME"
rsync -a "${RSYNC_EXCLUDES[@]}" "$ROOT/" "$STAGE/$PKG_NAME/"

# --- Zip -------------------------------------------------------------------
# -X strips extra file attributes; run from the staging dir so the CritKing
# folder sits at the zip root.
( cd "$STAGE" && zip -r -X -q "$ZIP_PATH" "$PKG_NAME" )

# Clean up the staging copy, keep the zip.
rm -rf "$STAGE"

echo "==> Done: ${ZIP_PATH#$ROOT/}"
ls -lh "$ZIP_PATH" | awk '{print "    size:", $5}'
