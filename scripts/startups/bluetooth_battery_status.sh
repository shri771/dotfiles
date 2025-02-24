#!/bin/bash

# Get battery percentage from Bluetooth device
DEVICE_NAME="realme Buds"
BATTERY=$(bluetoothctl info | grep "Battery Percentage" | awk '{print $3}' | tr -d '%')

# Determine color based on battery level
if [[ -z "$BATTERY" ]]; then
    COLOR="#888888"  # Default gray if no battery info
elif (( BATTERY >= 70 )); then
    COLOR="#00ff00"  # Green (Good battery)
elif (( BATTERY >= 40 )); then
    COLOR="#ffff00"  # Yellow (Medium battery)
elif (( BATTERY >= 20 )); then
    COLOR="#ff9900"  # Orange (Low battery)
else
    COLOR="#ff0000"  # Red (Critical battery)
fi

# Output JSON for Waybar
echo "{\"text\": \"\", \"battery_color\": \"$COLOR\"}"
