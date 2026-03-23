#!/usr/bin/env bash

CONFIG="$HOME/.config/hypr/hyprland.conf"

# Parse bind lines and format them
grep -E '^\s*bind\s*=' "$CONFIG" |
  sed 's/^\s*bind\s*=\s*//' |
  awk -F',' '{
    mods=$1; key=$2; dispatcher=$3; arg=$4
    gsub(/^ +| +$/, "", mods)
    gsub(/^ +| +$/, "", key)
    gsub(/^ +| +$/, "", dispatcher)
    gsub(/^ +| +$/, "", arg)
    combo = (mods != "" ? mods " + " : "") key
    action = dispatcher (arg != "" ? "  →  " arg : "")
    printf "%-30s %s\n", combo, action
  }' |
  rofi -dmenu \
    -i \
    -p "Keybinds" \
    -no-custom \
    -format i
