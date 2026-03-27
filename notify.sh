#!/usr/bin/env bash
# claude-notify: Cross-platform notification script for Claude Code hooks
# Usage: notify.sh [stop|permission]

EVENT="${1:-stop}"
OS="$(uname -s 2>/dev/null || echo Windows)"

play_macos() {
  local sound="$1"
  afplay "/System/Library/Sounds/${sound}.aiff" 2>/dev/null
}

play_linux() {
  local sound_complete="/usr/share/sounds/freedesktop/stereo/complete.oga"
  local sound_bell="/usr/share/sounds/freedesktop/stereo/bell.oga"
  if command -v paplay >/dev/null 2>&1; then
    paplay "$sound_complete" 2>/dev/null || paplay "$sound_bell" 2>/dev/null
  elif command -v aplay >/dev/null 2>&1; then
    aplay -q "$sound_bell" 2>/dev/null
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "Claude Code" "Claude needs your attention" 2>/dev/null
  fi
}

play_windows() {
  local freq="$1"
  local dur="$2"
  powershell.exe -c "[console]::beep(${freq},${dur})" 2>/dev/null \
    || powershell -c "[console]::beep(${freq},${dur})" 2>/dev/null
}

case "$OS" in
  Darwin)
    case "$EVENT" in
      permission) play_macos "Ping" ;;
      *)          play_macos "Glass" ;;
    esac
    ;;
  Linux)
    play_linux
    ;;
  *)
    # Windows (Git Bash / WSL)
    case "$EVENT" in
      permission) play_windows 1200 400 ;;
      *)          play_windows 800 600 ;;
    esac
    ;;
esac
