#!/usr/bin/env bash
# claude-notify installer
# Copies notify.sh to ~/.claude/scripts/ and adds hooks to ~/.claude/settings.json

set -e

INSTALL_DIR="${HOME}/.claude/scripts/claude-notify"
SETTINGS_FILE="${HOME}/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing claude-notify..."

# Create install directory and copy script
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/notify.sh" "$INSTALL_DIR/notify.sh"
chmod +x "$INSTALL_DIR/notify.sh"
echo "  Installed notify.sh -> $INSTALL_DIR/notify.sh"

# Ensure settings.json exists with a valid JSON object
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "{}" > "$SETTINGS_FILE"
  echo "  Created $SETTINGS_FILE"
fi

NOTIFY_SCRIPT="$INSTALL_DIR/notify.sh"

# Use Python to safely merge hook entries into settings.json
python3 - "$SETTINGS_FILE" "$NOTIFY_SCRIPT" <<'EOF'
import json
import sys

settings_path = sys.argv[1]
notify_script = sys.argv[2]

with open(settings_path) as f:
    settings = json.load(f)

hooks = settings.setdefault("hooks", {})

# Stop hook
stop_hooks = hooks.setdefault("Stop", [])
stop_cmd = f"{notify_script} stop"
if not any(
    any(h.get("command") == stop_cmd for h in group.get("hooks", []))
    for group in stop_hooks
):
    stop_hooks.append({
        "matcher": "",
        "hooks": [{"type": "command", "command": stop_cmd}]
    })

# PermissionRequest hook
perm_hooks = hooks.setdefault("PermissionRequest", [])
perm_cmd = f"{notify_script} permission"
if not any(
    any(h.get("command") == perm_cmd for h in group.get("hooks", []))
    for group in perm_hooks
):
    perm_hooks.append({
        "matcher": "",
        "hooks": [{"type": "command", "command": perm_cmd}]
    })

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print(f"  Updated {settings_path}")
EOF

echo ""
echo "Done! claude-notify is installed."
echo "  Stop sound:      Glass.aiff (macOS) / bell (Linux) / 800Hz beep (Windows)"
echo "  Permission sound: Ping.aiff (macOS) / bell (Linux) / 1200Hz beep (Windows)"
echo ""
echo "To uninstall, run: ./uninstall.sh"
