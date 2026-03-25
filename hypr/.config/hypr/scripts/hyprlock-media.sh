#!/usr/bin/env bash
if command -v playerctl &>/dev/null && playerctl status &>/dev/null 2>&1; then
  artist=$(playerctl metadata artist 2>/dev/null)
  title=$(playerctl metadata title 2>/dev/null)
  if [[ -n "$artist" && -n "$title" ]]; then
    echo "󰎈  $artist — $title"
  elif [[ -n "$title" ]]; then
    echo "󰎈  $title"
  fi
fi
