#!/usr/bin/env bash
# Converts Resources/icon_source.png (ideally 1024x1024, square) into
# AppIcon.iconset/ at every size macOS needs, using sips (built into
# macOS — no ImageMagick or other dependency), then packages the result
# into Resources/AppIcon.icns with iconutil.
#
# Use this instead of Scripts/generate_icon.swift when you already have
# a finished icon image and just want it converted, rather than having
# one drawn procedurally.
set -euo pipefail

cd "$(dirname "$0")/.."

SOURCE_PNG="Resources/icon_source.png"
ICONSET_DIR="AppIcon.iconset"

if [ ! -f "$SOURCE_PNG" ]; then
    echo "Error: no existe $SOURCE_PNG." >&2
    echo "Guarda ahí tu imagen (idealmente 1024x1024, cuadrada, PNG) y vuelve a correr este script." >&2
    exit 1
fi

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

SIZES=(
    "16 icon_16x16"
    "32 icon_16x16@2x"
    "32 icon_32x32"
    "64 icon_32x32@2x"
    "128 icon_128x128"
    "256 icon_128x128@2x"
    "256 icon_256x256"
    "512 icon_256x256@2x"
    "512 icon_512x512"
    "1024 icon_512x512@2x"
)

for entry in "${SIZES[@]}"; do
    read -r pixels name <<< "$entry"
    sips -z "$pixels" "$pixels" "$SOURCE_PNG" --out "$ICONSET_DIR/$name.png" > /dev/null
    echo "Generado $name.png (${pixels}x${pixels})"
done

iconutil -c icns "$ICONSET_DIR" -o Resources/AppIcon.icns
rm -rf "$ICONSET_DIR"

echo ""
echo "Listo: Resources/AppIcon.icns"
echo "Ahora recompila con: ./Scripts/build_app.sh"
