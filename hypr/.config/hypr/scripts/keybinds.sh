#!/usr/bin/env bash
# ============================================================
#  KEYBINDS VIEWER
#  Shows all Hyprland keybindings in rofi
# ============================================================

CONFIG="$HOME/.config/hypr/hyprland.conf"

# Resolve $mainMod and $mod variable values from config
MAINMOD=$(grep -E '^\s*\$mainMod\s*=' "$CONFIG" | sed 's/.*=\s*//' | tr -d '[:space:]')
MOD=$(grep -E '^\s*\$mod\s*=' "$CONFIG" | sed 's/.*=\s*//' | tr -d '[:space:]')

grep -E '^\s*bind[melr]?\s*=' "$CONFIG" |
  sed 's/^\s*bind[melr]\?\s*=\s*//' |
  sed "s/\$mainMod/$MAINMOD/g" |
  sed "s/\$mod/$MOD/g" |
  awk -F',' '{
        mods = $1; key = $2; dispatcher = $3; arg = $4
        gsub(/^ +| +$/, "", mods)
        gsub(/^ +| +$/, "", key)
        gsub(/^ +| +$/, "", dispatcher)
        gsub(/^ +| +$/, "", arg)
        combo  = (mods != "" ? mods " + " : "") key
        action = dispatcher (arg != "" ? "  →  " arg : "")
        printf "%-36s %s\n", combo, action
    }' |
  rofi -dmenu \
    -i \
    -p "Keybinds" \
    -no-custom \
    -theme-str '
           window {
               width: 900px;
           }
           listview {
               lines: 20;
           }
           element-text {
               font: "CaskaydiaCove Nerd Font 11";
           }
           '
