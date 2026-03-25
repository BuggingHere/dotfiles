#!/usr/bin/env bash
# ============================================================
#  FOCUS MODE TOGGLE
#  Removes gaps, borders, and waybar for distraction-free work
# ============================================================

STATE_FILE="/tmp/hypr_focus_mode"

if [[ -f "$STATE_FILE" ]]; then
  hyprctl reload
  waybar &
  disown
  rm "$STATE_FILE"
  notify-send "Focus Mode" "Off" -i preferences-desktop
else
  hyprctl keyword general:gaps_in 0
  hyprctl keyword general:gaps_out 0
  hyprctl keyword general:border_size 0
  hyprctl keyword decoration:rounding 0
  pkill waybar
  touch "$STATE_FILE"
  notify-send "Focus Mode" "On" -i preferences-desktop
fi
