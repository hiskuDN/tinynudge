#!/usr/bin/env bash
# claude-notify: Cross-platform notification script for Claude Code hooks
# Usage: notify.sh [stop|permission]

EVENT="${1:-stop}"
OS="$(uname -s 2>/dev/null || echo Windows)"

# Set to "true" to bring your editor to focus immediately when the notification
# fires, instead of waiting for you to click it.
ACTIVATE_IMMEDIATELY="${CLAUDE_NOTIFY_ACTIVATE_IMMEDIATELY:-false}"

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

  local immediately_flag=""
  [[ "${ACTIVATE_IMMEDIATELY}" == "true" ]] && immediately_flag="--activate-immediately"

  # Find claude-notifier: PATH, ~/.local/bin, Homebrew prefix, or ~/Applications
  local notifier_bin
  for candidate in \
    "$(command -v claude-notifier 2>/dev/null)" \
    "$HOME/.local/bin/claude-notifier" \
    "$(brew --prefix 2>/dev/null)/bin/claude-notifier" \
    "$HOME/Applications/claude-notifier.app/Contents/MacOS/claude-notifier"; do
    if [[ -x "$candidate" ]]; then
      notifier_bin="$candidate"
      break
    fi
  done

  # Find the .app bundle: Homebrew Cellar, ~/Applications, or next to this script
  local app_bundle
  for candidate in \
    "$(brew --prefix 2>/dev/null)/opt/claude-notifier/claude-notifier.app" \
    "$HOME/Applications/claude-notifier.app" \
    "$(dirname "$0")/claude-notifier.app"; do
    if [[ -d "$candidate" ]]; then
      app_bundle="$candidate"
      break
    fi
  done

  if [[ -n "$app_bundle" ]]; then
    # Launch via `open -a` so LaunchServices registers it — required for click-to-focus
    open -a "$app_bundle" --args \
      --title "${title}" --message "${message}" \
      --sound "${sound}" --activate "${bundle_id}" ${immediately_flag}
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
