#!/usr/bin/env bash
# tinynudge: Cross-platform notifications for AI coding agent hooks
# Usage: notify.sh <agent> <event>
#   agent: claude-code | cursor | gemini | codex | <any name>
#   event: stop | permission
# Example: notify.sh claude-code stop

AGENT="${1:-agent}"
EVENT="${2:-stop}"
OS="$(uname -s 2>/dev/null || echo Windows)"

# Set to "true" to bring your editor to focus immediately when the notification
# fires, instead of waiting for you to click it.
ACTIVATE_IMMEDIATELY="${TINYNUDGE_ACTIVATE_IMMEDIATELY:-false}"

# Pretty-print the agent name for the notification title
agent_label() {
  case "$1" in
    claude-code) echo "Claude Code" ;;
    cursor)      echo "Cursor" ;;
    gemini)      echo "Gemini" ;;
    codex)       echo "Codex" ;;
    *)           echo "$1" ;;
  esac
}

notify_macos() {
  local title="$1"
  local message="$2"
  local sound="$3"

  # Detect terminal / editor bundle ID for click-to-focus
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

  # Map bundle ID → System Events process name for window-title capture
  local process_name
  case "$bundle_id" in
    com.todesktop.230313mzl4w4u92) process_name="Cursor" ;;
    com.microsoft.VSCode)           process_name="Code" ;;
    com.googlecode.iterm2)          process_name="iTerm2" ;;
    dev.warp.Warp-Stable)           process_name="Warp" ;;
    com.mitchellh.ghostty)          process_name="Ghostty" ;;
    com.apple.Terminal)             process_name="Terminal" ;;
    *)                              process_name="" ;;
  esac

  # Identify the source window by matching the project name ($PWD basename)
  # to window titles. This lets us suppress and focus the right window even
  # when multiple windows of the same app are open.
  local win_title=""
  if [[ -n "$process_name" ]]; then
    local project_name
    project_name=$(basename "$PWD")
    win_title=$(osascript \
      -e "tell application \"System Events\"" \
      -e "  tell process \"${process_name}\"" \
      -e "    try" \
      -e "      get title of first window whose title contains \"${project_name}\"" \
      -e "    end try" \
      -e "  end tell" \
      -e "end tell" 2>/dev/null)
  fi

  # Suppress banner only if the exact source window is currently frontmost
  local frontmost_id
  frontmost_id=$(osascript -e "id of app (path to frontmost application as text)" 2>/dev/null)
  if [[ "$frontmost_id" == "$bundle_id" && -n "$process_name" && -n "$win_title" ]]; then
    local frontmost_win
    frontmost_win=$(osascript \
      -e "tell application \"System Events\"" \
      -e "  tell process \"${process_name}\"" \
      -e "    get title of window 1" \
      -e "  end tell" \
      -e "end tell" 2>/dev/null)
    if [[ "$frontmost_win" == "$win_title" ]]; then
      afplay "/System/Library/Sounds/${sound}.aiff" 2>/dev/null
      return
    fi
  fi

  # Find the tinynudge .app bundle: Homebrew Cellar, ~/Applications, or repo
  local app_bundle
  for candidate in \
    "$(brew --prefix 2>/dev/null)/opt/tinynudge/tinynudge.app" \
    "$HOME/Applications/tinynudge.app" \
    "$(dirname "$0")/tinynudge.app" \
    "$(dirname "$0")/build/tinynudge.app"; do
    if [[ -d "$candidate" ]]; then
      app_bundle="$candidate"
      break
    fi
  done

  if [[ -n "$app_bundle" ]]; then
    # Build args array — avoids quoting hazards with window titles containing spaces
    local open_args=(
      --args
      --title "${title}" --message "${message}"
      --sound "${sound}" --activate "${bundle_id}"
    )
    [[ "${ACTIVATE_IMMEDIATELY}" == "true" ]] && open_args+=(--activate-immediately)
    [[ -n "$win_title" ]] && open_args+=(--window-title "${project_name}")
    [[ -n "${VSCODE_IPC_HOOK_CLI}" ]] && open_args+=(--ipc-hook "${VSCODE_IPC_HOOK_CLI}")
    open_args+=(--project-path "${PWD}")
    # Launch via `open -a` so LaunchServices registers it — required for click-to-focus
    open -a "$app_bundle" "${open_args[@]}"
  else
    # Fallback: osascript notification + sound (no click-to-focus)
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
    notify-send "$(agent_label "$AGENT")" "Needs your attention" 2>/dev/null
  fi
}

play_windows() {
  local freq="$1"
  local dur="$2"
  powershell.exe -c "[console]::beep(${freq},${dur})" 2>/dev/null \
    || powershell -c "[console]::beep(${freq},${dur})" 2>/dev/null
}

TITLE="$(agent_label "$AGENT")"

case "$OS" in
  Darwin)
    case "$EVENT" in
      permission) notify_macos "$TITLE" "Waiting for your approval" "Ping" ;;
      *)          notify_macos "$TITLE" "Done" "Glass" ;;
    esac
    ;;
  Linux)
    play_linux
    ;;
  *)
    case "$EVENT" in
      permission) play_windows 1200 400 ;;
      *)          play_windows 800 600 ;;
    esac
    ;;
esac
