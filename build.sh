#!/bin/bash
# Builds Caffeine.app into ~/Applications.
set -euo pipefail
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
APP="$HOME/Applications/Caffeine.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>CFBundleName</key><string>Caffeine</string>
    <key>CFBundleExecutable</key><string>Caffeine</string>
    <key>CFBundleIdentifier</key><string>com.kirtan.caffeine</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
</dict></plist>
PLIST
swiftc -O -target x86_64-apple-macosx13.0 \
    -framework Cocoa -framework IOKit -framework ServiceManagement \
    -o "$APP/Contents/MacOS/Caffeine" "$SRC_DIR/Sources/main.swift"
codesign --force --deep --sign - "$APP"
echo "Built: $APP"
