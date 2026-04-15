<div align="center">
  <img src="assets/logo_full.png" alt="tinynudge" width="300" />
  <p><strong>A tiny notifier for AI coding agents.</strong></p>
  <p>Get a banner + sound when your agent finishes a task or pauses for your approval — step away without missing a beat.</p>
</div>

---

## Supports

| Agent | Status |
|-------|--------|
| Claude Code | ✅ |
| Cursor | ✅ |
| Gemini CLI | ✅ *(experimental)* |
| Codex | ✅ *(experimental)* |
| Any hooks-capable agent | ✅ — point it at `notify.sh` |

**Platforms:** macOS (native banners + click-to-focus) · Linux (PulseAudio / ALSA / libnotify) · Windows (Git Bash / WSL)

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
| Gemini CLI | session end | Banner when agent finishes |

The hook calls `notify.sh <agent> <event>`, which plays a sound and shows a banner via:

1. **macOS** — the native `tinynudge.app` (click-to-focus routes back to your editor)
2. **Linux** — `paplay` / `aplay` / `notify-send`
3. **Windows** — `powershell [console]::beep`

### Click-to-focus (macOS)

When you click the banner, macOS re-launches `tinynudge.app`, which detects your terminal / editor and brings it to the front via ScriptingBridge. Detected apps:

- Cursor (`com.todesktop.230313mzl4w4u92`) — via `$CURSOR_TRACE_ID`
- VS Code (`com.microsoft.VSCode`)
- iTerm2, Warp, Ghostty, Terminal.app

### Immediate focus mode

If you'd rather have your editor focus automatically — no click needed:

```bash
export TINYNUDGE_ACTIVATE_IMMEDIATELY=true
```

Add that to your shell profile.

## Sounds

| Event | macOS | Linux | Windows |
|-------|-------|-------|---------|
| Agent done | `Glass.aiff` | freedesktop bell | 800 Hz beep |
| Waiting for approval | `Ping.aiff` | freedesktop bell | 1200 Hz beep |

Any file from `/System/Library/Sounds/` works on macOS: Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink.

## Uninstall

```bash
./uninstall.sh
```

Removes the hooks from each agent's config and deletes `~/.tinynudge/`. To also remove the binary: `brew uninstall tinynudge`.

## Manual setup

Every supported agent just needs a hook that runs `notify.sh <agent-name> <event>`. Example for Codex (or any other hooks-capable agent):

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

The Swift source lives in `notifier/` — ~150 lines, compiled with `swiftc`. No Xcode, no SPM, no dependencies.

## Credits

Click-routing architecture (process exits after delivery, macOS re-launches on click) is adapted from [`terminal-notifier`](https://github.com/julienXX/terminal-notifier) by Eloy Durán and Julien Blanchard.

## License

MIT
