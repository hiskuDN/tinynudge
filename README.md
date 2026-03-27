# claude-notify

A Claude Code plugin that plays sounds when Claude finishes a response or pauses waiting for your permission.

## Sounds

| Event | macOS | Linux | Windows |
|-------|-------|-------|---------|
| Claude done | `Glass.aiff` | freedesktop bell | 800Hz beep |
| Waiting for permission | `Ping.aiff` | freedesktop bell | 1200Hz beep |

## Installation

### Option 1: Install script (recommended)

```bash
git clone https://github.com/yourusername/claude-notify.git
cd claude-notify
./install.sh
```

This copies `notify.sh` to `~/.claude/scripts/claude-notify/` and adds the hooks to `~/.claude/settings.json`.

### Option 2: Manual

Add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Glass.aiff"
          }
        ]
      }
    ],
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Ping.aiff"
          }
        ]
      }
    ]
  }
}
```

Replace the `afplay` commands with your platform's sound command (see [Customization](#customization) below).

### Option 3: Claude Code plugin system

If you have the Claude Code plugin system available:

```bash
claude --plugin-dir ./claude-notify
```

## Uninstall

```bash
./uninstall.sh
```

## Customization

Edit `~/.claude/scripts/claude-notify/notify.sh` to change sounds.

**macOS sounds** are in `/System/Library/Sounds/`: Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink.

**Linux**: Replace `paplay` with `notify-send "Claude Code" "Done"` for a desktop notification instead of a sound.

**Windows**: Adjust the frequency (Hz) and duration (ms) in `play_windows` calls.

## How it works

Claude Code's [hooks system](https://docs.anthropic.com/en/docs/claude-code/hooks) lets you run shell commands in response to events:

- `Stop` — fires when Claude finishes a response
- `PermissionRequest` — fires when Claude pauses and needs your approval to proceed

## Requirements

- Claude Code CLI
- macOS / Linux / Windows (Git Bash or WSL)
- Python 3 (for the install script only)

## License

MIT
