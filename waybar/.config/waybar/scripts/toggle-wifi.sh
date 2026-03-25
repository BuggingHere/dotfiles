#!/usr/bin/env bash
# ============================================================
#  TOGGLE WIFI
#  Connects/disconnects wifi without turning the radio off
#  so the waybar network module stays visible
# ============================================================

INTERFACE=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1; exit}')

if [[ -z "$INTERFACE" ]]; then
  notify-send "WiFi" "No wifi interface found" -i network-wireless-offline
  exit 1
fi

STATE=$(nmcli -t -f DEVICE,STATE device | awk -F: -v iface="$INTERFACE" '$1==iface{print $2; exit}')

if [[ "$STATE" == "connected" ]]; then
  nmcli device disconnect "$INTERFACE"
  notify-send "WiFi" "Disconnected from network" -i network-wireless-offline
else
  nmcli device connect "$INTERFACE"
  notify-send "WiFi" "Connecting..." -i network-wireless
fi
