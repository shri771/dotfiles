#!/bin/bash


# Bluetooth Device MAC Address
BT_DEVICE_MAC="98:47:44:77:AA:AA"

sudo systemctl restart bluetooth.service
sleep 0.1
# 1. Check if the device is paired with the system.
device_info=$(bluetoothctl info "$BT_DEVICE_MAC" 2>/dev/null)
if [ -z "$device_info" ]; then
    exit 0
fi

# 2. Check if the device is already connected.
if echo "$device_info" | grep -q "Connected: yes"; then
    exit 0
fi

# 3. Check if Bluetooth service is active.
if ! systemctl is-active --quiet bluetooth; then
    exit 1
fi

# 4. Attempt to connect silently.
if bluetoothctl connect "$BT_DEVICE_MAC" >/dev/null 2>&1; then
    # 5. If and only if the connection succeeds, send a notification.
    notify-send -i "/home/sh/.icons/WhiteSur-dark/apps@2x/scalable/bluetooth.svg" "Bluetooth Connected" "Realme Buds connected successfully!"
fi

exit 0
