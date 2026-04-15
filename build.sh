#!/usr/bin/env bash
# Builds claude-notifier.app and a CLI shim
# Usage: ./build.sh [arm64|x86_64]  (defaults to host arch)

set -e

ARCH="${1:-$(uname -m)}"
APP="build/claude-notifier.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"

echo "Building claude-notifier ($ARCH)..."

rm -rf build && mkdir -p "$MACOS"

swiftc \
  notifier/main.swift \
  notifier/Config.swift \
  notifier/Notifier.swift \
  notifier/AppActivator.swift \
  -o "$MACOS/claude-notifier" \
  -target "${ARCH}-apple-macos12.0" \
  -framework Foundation \
  -framework UserNotifications \
  -framework AppKit

cp notifier/Info.plist "$CONTENTS/Info.plist"

echo "  Built $APP"
echo "  Binary: $(file "$MACOS/claude-notifier")"
