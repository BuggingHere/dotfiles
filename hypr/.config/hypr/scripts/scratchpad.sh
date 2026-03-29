#!/usr/bin/env bash
# ============================================================
#  SCRATCHPAD
#  Toggles scratchpad terminal, launches if not running
# ============================================================

TITLE="scratchpad"

# Check if scratchpad window exists anywhere
ADDR=$(hyprctl clients -j | python3 -c "
import sys, json
clients = json.load(sys.stdin)
for c in clients:
    if c.get('title', '') == '$TITLE':
        print(c['address'])
        break
")

if [[ -z "$ADDR" ]]; then
  # Not running — launch directly into scratchpad workspace
  hyprctl dispatch exec "[workspace special:scratchpad silent] kitty --title $TITLE"
else
  # Already running — toggle visibility
  hyprctl dispatch togglespecialworkspace scratchpad
fi
