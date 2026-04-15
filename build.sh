#!/usr/bin/env bash
# Builds tinynudge.app (macOS notification binary)
# Usage: ./build.sh [arm64|x86_64]  (defaults to host arch)

set -e

ARCH="${1:-$(uname -m)}"
APP="build/tinynudge.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"

echo "Building tinynudge ($ARCH)..."

rm -rf build && mkdir -p "$MACOS"

swiftc \
  notifier/main.swift \
  notifier/Config.swift \
  notifier/Notifier.swift \
  notifier/AppActivator.swift \
  -o "$MACOS/tinynudge" \
  -target "${ARCH}-apple-macos12.0" \
  -framework Foundation \
  -framework AppKit \
  -framework ScriptingBridge

cp notifier/Info.plist "$CONTENTS/Info.plist"

echo "  Built $APP"
echo "  Binary: $(file "$MACOS/tinynudge")"
