#!/usr/bin/env bash
# Builds RedScreen with Swift Package Manager and wraps the resulting
# executable in a minimal .app bundle (RedScreen only ships an SPM package,
# not an .xcodeproj, so this replaces Xcode's usual app-bundling step).
set -euo pipefail

APP_NAME="RedScreen"
BUILD_CONFIG="release"

cd "$(dirname "$0")/.."

swift build -c "$BUILD_CONFIG"

BIN_PATH="$(swift build -c "$BUILD_CONFIG" --show-bin-path)"
APP_BUNDLE="$BIN_PATH/$APP_NAME.app"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BIN_PATH/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "Built $APP_BUNDLE"
echo "Run it with: open \"$APP_BUNDLE\""
