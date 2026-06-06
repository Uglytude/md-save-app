#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="MD Save"
EXECUTABLE="MDSave"
BUILD_DIR="$ROOT/build"
APP="$BUILD_DIR/$APP_NAME.app"
ICONSET="$BUILD_DIR/AppIcon.iconset"
ICON_PNG="$ROOT/assets/AppIcon.png"
ICON_ICNS="$BUILD_DIR/AppIcon.icns"

rm -rf "$APP" "$ICONSET"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$ICONSET"

cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"

if [[ ! -f "$ICON_PNG" ]]; then
  echo "Missing icon asset: $ICON_PNG" >&2
  exit 1
fi

make_icon() {
  local size="$1"
  local name="$2"
  sips -z "$size" "$size" "$ICON_PNG" --out "$ICONSET/$name" >/dev/null
}

make_icon 16 "icon_16x16.png"
make_icon 32 "icon_16x16@2x.png"
make_icon 32 "icon_32x32.png"
make_icon 64 "icon_32x32@2x.png"
make_icon 128 "icon_128x128.png"
make_icon 256 "icon_128x128@2x.png"
make_icon 256 "icon_256x256.png"
make_icon 512 "icon_256x256@2x.png"
make_icon 512 "icon_512x512.png"
make_icon 1024 "icon_512x512@2x.png"

iconutil -c icns "$ICONSET" -o "$ICON_ICNS"
cp "$ICON_ICNS" "$APP/Contents/Resources/AppIcon.icns"

swiftc "$ROOT/Sources/main.swift" -framework AppKit -o "$APP/Contents/MacOS/$EXECUTABLE"
chmod +x "$APP/Contents/MacOS/$EXECUTABLE"

xattr -cr "$APP" 2>/dev/null || true
codesign --force --deep --sign - "$APP"
codesign --verify --deep "$APP"

echo "Built $APP"
