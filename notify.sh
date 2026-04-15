#!/usr/bin/env bash
# claude-notify: Cross-platform notification script for Claude Code hooks
# Usage: notify.sh [stop|permission]

EVENT="${1:-stop}"
OS="$(uname -s 2>/dev/null || echo Windows)"

notify_macos() {
  local title="$1"
  local message="$2"
  local sound="$3"

  # Detect terminal app bundle ID for click-to-focus
  local bundle_id
  case "${TERM_PROGRAM}" in
    vscode)
      if [[ -n "${CURSOR_TRACE_ID}" ]]; then
        bundle_id="com.todesktop.230313mzl4w4u92"  # Cursor
      else
        bundle_id="com.microsoft.VSCode"
      fi
      ;;
    iTerm.app)    bundle_id="com.googlecode.iterm2" ;;
    WarpTerminal) bundle_id="dev.warp.Warp-Stable" ;;
    ghostty)      bundle_id="com.mitchellh.ghostty" ;;
    *)            bundle_id="com.apple.Terminal" ;;
  esac

  if command -v claude-notifier >/dev/null 2>&1; then
    claude-notifier --title "${title}" --message "${message}" \
      --sound "${sound}" --activate "${bundle_id}"
  elif command -v terminal-notifier >/dev/null 2>&1; then
    afplay "/System/Library/Sounds/${sound}.aiff" 2>/dev/null &
    terminal-notifier -title "${title}" -message "${message}" \
      -sound "${sound}" -activate "${bundle_id}" 2>/dev/null
  else
    afplay "/System/Library/Sounds/${sound}.aiff" 2>/dev/null &
    osascript -e "display notification \"${message}\" with title \"${title}\" sound name \"${sound}\"" 2>/dev/null
  fi
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
      permission) notify_macos "Claude Code" "Waiting for your approval" "Ping" ;;
      *)          notify_macos "Claude Code" "Done" "Glass" ;;
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
