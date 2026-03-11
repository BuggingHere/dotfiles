#!/bin/bash

HYPRLAND_DEVICE="syna801a:00-06cb:cec6-touchpad"
STATUS_FILE="/tmp/touchpad_status"

# Function to enable the touchpad
enable_touchpad() {
  printf "true" >"$STATUS_FILE"
  notify-send -u low "Touchpad Enabled"
  hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" true
}

# Function to disable the touchpad
disable_touchpad() {
  printf "false" >"$STATUS_FILE"
  notify-send -u low "Touchpad Disabled"
  hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" false
}

# Toggle the state
if [ -f "$STATUS_FILE" ]; then
  if [ $(cat "$STATUS_FILE") = "true" ]; then
    disable_touchpad
  else
    enable_touchpad
  fi
else
  # Default to enabled if status file doesn't exist
  enable_touchpad
fi
