# tinynudge

A tiny notifier for AI coding agents. Get a banner + sound when your agent finishes a task or pauses for your approval, so you can step away without missing anything.

Works with:

- Claude Code
- Cursor
- Gemini CLI *(experimental)*
- Codex *(experimental)*
- Any agent with a hooks system — just point it at `notify.sh`

Supports macOS (native Notification Center banners with click-to-focus), Linux (PulseAudio / ALSA / libnotify), and Windows (Git Bash / WSL beeps).

## Install

```bash
git clone https://github.com/hiskuDN/tinynudge.git
cd tinynudge
./install.sh
```

The installer auto-detects which agents you have configured (`~/.claude`, `~/.cursor`, `~/.gemini`) and wires up their hooks.

On macOS it also installs the native `tinynudge.app` via Homebrew tap for click-to-focus banners:

```bash
brew install hiskuDN/tap/tinynudge
```

Without the binary, macOS falls back to `osascript` notifications (no click-to-focus).

## How it works

Each supported agent has a hooks system. `tinynudge` registers these hooks:

| Agent | Event | What happens |
|-------|-------|--------------|
| Claude Code | `Stop` | Banner when the turn ends |
| Claude Code | `PermissionRequest` | Banner when Claude pauses for approval |
| Cursor | `stop` | Banner when agent turn ends |
| Gemini CLI | session end (experimental) | Banner when agent finishes |

The hook calls `notify.sh <agent> <event>`, which plays a sound and shows a banner via:

1. **macOS:** the native `tinynudge.app` binary (click-to-focus routes back to your editor)
2. **Linux:** `paplay` / `aplay` / `notify-send`
3. **Windows:** `powershell [console]::beep`

### Click-to-focus (macOS)

When you click the banner, macOS re-launches `tinynudge.app` which detects your terminal / editor and brings it to front via `ScriptingBridge`. We detect:

- Cursor (`com.todesktop.230313mzl4w4u92`) — via `$CURSOR_TRACE_ID`
- VS Code (`com.microsoft.VSCode`)
- iTerm2, Warp, Ghostty, Terminal.app

### Immediate focus mode

If you'd rather have your editor come to focus automatically (no click needed):

```bash
export TINYNUDGE_ACTIVATE_IMMEDIATELY=true
```

Add that to your shell profile.

## Sounds

| Event | macOS sound | Linux | Windows |
|-------|-------------|-------|---------|
| Agent done | `Glass.aiff` | freedesktop bell | 800Hz beep |
| Waiting for permission | `Ping.aiff` | freedesktop bell | 1200Hz beep |

macOS sounds are anything in `/System/Library/Sounds/` — Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink.

## Uninstall

```bash
./uninstall.sh
```

Removes the hooks from each agent's config and deletes `~/.tinynudge/`. The Homebrew binary can be removed separately: `brew uninstall tinynudge`.

## Manual setup (if the installer doesn't cover your agent)

Every supported agent just needs a hook that runs `notify.sh <agent-name> <event>`. For example, for Codex (or any other hooks-capable agent):

```json
{
  "hooks": {
    "stop": [
      {
        "type": "command",
        "command": "$HOME/.tinynudge/notify.sh codex stop"
      }
    ]
  }
}
```

## Development

```bash
./build.sh            # builds tinynudge.app into build/
```

The Swift source is in `notifier/`. It's a tiny app (~150 lines) built with `swiftc` — no Xcode project, no SPM, no dependencies.

## Credits

- Architecture for click-routing on macOS (process exits after delivery, macOS re-launches on click) is adapted from [`terminal-notifier`](https://github.com/julienXX/terminal-notifier) by Eloy Durán and Julien Blanchard.

## License

MIT
