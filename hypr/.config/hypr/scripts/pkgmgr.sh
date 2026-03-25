#!/usr/bin/env bash
# ============================================================
#  PKGMGR
#  Launches a floating kitty window with fzf-pacman
# ============================================================
kitty \
  --title "pkgmgr" \
  --override font_size=11 \
  --override initial_window_width=900 \
  --override initial_window_height=600 \
  --override background_opacity=0.85 \
  bash -c '
source ~/.config/bash/fzf-pacman.sh

while true; do
    CHOICE=$(printf "  Install\n  Remove\n  Orphans\n  AUR Install\n  AUR Remove\n  Info\n  Update\n  Log\n  Quit" \
        | rofi \
            -dmenu \
            -i \
            -p "Packages ❯" \
            -no-custom \
            -theme-str "
            window   { width: 400px; }
            listview { lines: 9;     }
            ")

    case "$CHOICE" in
        *"AUR Install")   fzf-pacman aur install ;;
        *"AUR Remove")    fzf-pacman aur remove  ;;
        *"Install")       fzf-pacman install     ;;
        *"Remove")        fzf-pacman remove      ;;
        *"Orphans")       fzf-pacman orphans     ;;
        *"Info")          fzf-pacman info        ;;
        *"Update")        fzf-pacman update      ;;
        *"Log")           fzf-pacman log         ;;
        *"Quit"|"")       exit 0                 ;;
    esac

    echo ""
    read -r -p "Press Enter to return to menu..."
done
'
