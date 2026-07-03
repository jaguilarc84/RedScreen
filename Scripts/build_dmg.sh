#!/usr/bin/env bash
# Builds RedScreen and packages it into a distributable .dmg with the
# standard "drag the app onto Applications" layout, using only tools
# built into macOS (hdiutil) — no code signing or notarization involved.
# See README.md for what real distribution (no Gatekeeper warning) needs.
set -euo pipefail

cd "$(dirname "$0")/.."

APP_DISPLAY_NAME="RedScreen by Make It Happen LAB"
VOLUME_NAME="RedScreen"
DMG_PATH="dist/RedScreen-1.0.dmg"

./Scripts/build_app.sh

BIN_PATH="$(swift build -c release --show-bin-path)"
APP_BUNDLE="$BIN_PATH/$APP_DISPLAY_NAME.app"

STAGING_DIR="$(mktemp -d)"
cp -R "$APP_BUNDLE" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

mkdir -p dist
rm -f "$DMG_PATH"
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_PATH"

rm -rf "$STAGING_DIR"

echo "Listo: $DMG_PATH"
echo "Ábrelo con: open \"$DMG_PATH\""
