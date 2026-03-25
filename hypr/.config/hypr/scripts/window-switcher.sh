#!/usr/bin/env bash
# ============================================================
#  WINDOW SWITCHER
#  Fuzzy switch between open windows using rofi + hyprctl
# ============================================================

CLIENTS=$(hyprctl clients -j)

# Build rofi entries: workspace | class | title → address in info field
ENTRIES=$(echo "$CLIENTS" | python3 -c "
import sys, json

data = json.load(sys.stdin)
for w in data:
    addr  = w.get('address', '')
    cls   = w.get('class', 'unknown')
    title = w.get('title', 'untitled')
    ws    = w.get('workspace', {}).get('id', '?')

    if len(title) > 50:
        title = title[:47] + '...'

    print(f'WS {ws:<3}  {cls:<24}  {title}\x00info\x1f{addr}')
")

[[ -z "$ENTRIES" ]] && notify-send "Window Switcher" "No open windows." && exit 0

# Show rofi and get selected index
SELECTION=$(echo "$ENTRIES" | rofi \
  -dmenu \
  -i \
  -p "Switch ❯" \
  -format "i" \
  -no-custom \
  -theme-str '
    window    { width: 700px; }
    listview  { lines: 12; }
    element-text { font: "JetBrainsMono Nerd Font Propo 11"; }
    ')

[[ -z "$SELECTION" ]] && exit 0

# Extract address from the selected line's info field
ADDR=$(echo "$ENTRIES" | awk -v n="$((SELECTION + 1))" 'NR==n' | grep -oP '(?<=\x1f)0x[0-9a-f]+')

[[ -z "$ADDR" ]] && exit 1

hyprctl dispatch focuswindow "address:$ADDR"
