#!/usr/bin/env bash
# ============================================================
#  LAUNCH
#  Launch app on a specific workspace, focus if already open
#  Usage: launch.sh <workspace> <class|title:name> <command>
#  Examples:
#    launch.sh 1 class:kitty kitty
#    launch.sh 4 title:nvim "kitty --title nvim nvim"
# ============================================================

WS="$1"
MATCH="$2"
CMD="$3"

if [[ -z "$WS" || -z "$MATCH" || -z "$CMD" ]]; then
  echo "Usage: launch.sh <workspace> <class:name|title:name> <command>"
  exit 1
fi

if [[ "$MATCH" == title:* ]]; then
  FIELD="title"
  VALUE="${MATCH#title:}"
else
  FIELD="class"
  VALUE="${MATCH#class:}"
fi

# Find existing window — exclude scratchpad workspace and match exactly
EXISTING=$(hyprctl clients -j | python3 -c "
import sys, json
clients = json.load(sys.stdin)
for c in clients:
    # Skip scratchpad workspace
    if c.get('workspace', {}).get('name', '') == 'special:scratchpad':
        continue
    val = c.get('$FIELD', '').lower()
    if val == '$VALUE':
        print(c['address'])
        break
")

if [[ -n "$EXISTING" ]]; then
  hyprctl dispatch focuswindow "address:$EXISTING"
else
  hyprctl dispatch workspace "$WS"
  hyprctl dispatch exec "$CMD"
fi
