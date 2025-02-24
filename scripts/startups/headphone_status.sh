#!/bin/bash

# Check if Realme Buds are connected via Bluetooth
DEVICE_NAME="realme Buds"  # Change this if your device has a different name

if bluetoothctl info | grep -q "$DEVICE_NAME"; then
    ICON="󰋎"  # Headphones connected
    TOOLTIP="Connected to $DEVICE_NAME"
else
    ICON="󰋋"  # Headphones disconnected
    TOOLTIP="Not connected"
fi

# Output JSON for Waybar
echo "{\"text\": \"\", \"icon\": \"$ICON\", \"tooltip\": \"$TOOLTIP\"}"
