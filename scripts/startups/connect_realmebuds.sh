#!/bin/bash

# Log file for debugging
LOG_FILE="/tmp/realme_connect_debug.log"
echo "---" >> "$LOG_FILE"
echo "$(date): Script started" >> "$LOG_FILE"

# Bluetooth Device MAC Address
BT_DEVICE_MAC="98:47:44:77:AA:AA"

# 1. Check if the device is paired with the system.
echo "$(date): Checking if device is paired..." >> "$LOG_FILE"
device_info=$(bluetoothctl info "$BT_DEVICE_MAC" 2>/dev/null)
if [ -z "$device_info" ]; then
    echo "$(date): Device not paired. Exiting." >> "$LOG_FILE"
    exit 0
fi
echo "$(date): Device is paired." >> "$LOG_FILE"

# 2. Check if the device is already connected.
echo "$(date): Checking if device is connected..." >> "$LOG_FILE"
if echo "$device_info" | grep -q "Connected: yes"; then
    echo "$(date): Device already connected. Exiting." >> "$LOG_FILE"
    exit 0
fi
echo "$(date): Device is not connected." >> "$LOG_FILE"

# 3. Check if Bluetooth service is active.
echo "$(date): Checking if Bluetooth service is active..." >> "$LOG_FILE"
if ! systemctl is-active --quiet bluetooth; then
    echo "$(date): Bluetooth service is not active. Exiting." >> "$LOG_FILE"
    exit 1
fi
echo "$(date): Bluetooth service is active." >> "$LOG_FILE"

# 4. Attempt to connect silently.
echo "$(date): Attempting to connect..." >> "$LOG_FILE"
if bluetoothctl connect "$BT_DEVICE_MAC" >/dev/null 2>&1; then
    # 5. If and only if the connection succeeds, send a notification.
    echo "$(date): Connection successful. Sending notification." >> "$LOG_FILE"
    notify-send -i "/home/sh/.icons/WhiteSur-dark/apps@2x/scalable/bluetooth.svg" "Bluetooth Connected" "Realme Buds connected successfully!"
    echo "$(date): Notification sent." >> "$LOG_FILE"
else
    echo "$(date): Connection failed. Exiting silently." >> "$LOG_FILE"
fi

echo "$(date): Script finished." >> "$LOG_FILE"
exit 0
