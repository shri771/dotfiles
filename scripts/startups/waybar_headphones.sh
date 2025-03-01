#!/bin/bash

# Set the target MAC address
TARGET_MAC="98:47:44:77:AA:AA"

# Get the connected Bluetooth devices
DEVICE_INFO=$(bluetoothctl info)

# Extract MAC and battery percentage
CURRENT_MAC=$(echo "$DEVICE_INFO" | grep "Device" | awk '{print $2}')
BATTERY_PERCENT=$(echo "$DEVICE_INFO" | grep "Battery Percentage" | awk '{print $3}')

# Default JSON output (only icon)
OUTPUT="{\"text\": \"<span size='large'></span>\", \"tooltip\": \"No target device connected\"}"

# Check if the target device is connected
if [[ "$CURRENT_MAC" == "$TARGET_MAC" && -n "$BATTERY_PERCENT" ]]; then
    OUTPUT="{\"text\": \"<span size='large'></span> $BATTERY_PERCENT%\", \"tooltip\": \"Connected: $CURRENT_MAC - $BATTERY_PERCENT%\"}"
fi

# Print the JSON output for Waybar
echo $OUTPUT
