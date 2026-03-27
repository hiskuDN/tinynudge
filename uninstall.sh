#!/usr/bin/env bash
# claude-notify uninstaller

set -e

INSTALL_DIR="${HOME}/.claude/scripts/claude-notify"
SETTINGS_FILE="${HOME}/.claude/settings.json"
NOTIFY_SCRIPT="$INSTALL_DIR/notify.sh"

echo "Uninstalling claude-notify..."

# Remove hooks from settings.json
if [ -f "$SETTINGS_FILE" ]; then
  python3 - "$SETTINGS_FILE" "$NOTIFY_SCRIPT" <<'EOF'
import json
import sys

settings_path = sys.argv[1]
notify_script = sys.argv[2]
cmds = {f"{notify_script} stop", f"{notify_script} permission"}

with open(settings_path) as f:
    settings = json.load(f)

hooks = settings.get("hooks", {})
for event in list(hooks.keys()):
    hooks[event] = [
        group for group in hooks[event]
        if not all(h.get("command") in cmds for h in group.get("hooks", []))
    ]
    if not hooks[event]:
        del hooks[event]

if not hooks:
    settings.pop("hooks", None)

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print(f"  Removed hooks from {settings_path}")
EOF
fi

# Remove installed script
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "  Removed $INSTALL_DIR"
fi

echo ""
echo "Done! claude-notify has been uninstalled."
