#!/bin/bash

# Bluetooth Device MAC Address (Update this with your device's MAC)
BT_DEVICE_MAC="98:47:44:77:AA:AA"

# Exit if already disconnected
if ! bluetoothctl info "$BT_DEVICE_MAC" 2>/dev/null | grep -q "Connected: yes"; then
    exit 0
fi

# Function to check if Bluetooth is enabled
check_bluetooth() {
    if ! systemctl is-active --quiet bluetooth; then
        printf "Error: Bluetooth service is not active.\n" >&2
        return 1
    fi
}

# Function to disconnect from Bluetooth device
disconnect_bluetooth() {
    printf "Disconnecting from Bluetooth device %s...\n" "$BT_DEVICE_MAC"
    if ! bluetoothctl disconnect "$BT_DEVICE_MAC"; then
        printf "Error: Failed to disconnect from Bluetooth device %s.\n" "$BT_DEVICE_MAC" >&2
        notify-send -i "/home/sh/.icons/WhiteSur-dark/apps@2x/scalable/bluetooth.svg" "Bluetooth Disconnection Failed" "Failed to disconnect from Realme Buds."
        return 1
    fi

    printf "Successfully disconnected from %s.\n" "$BT_DEVICE_MAC"
    notify-send -i "/home/sh/.icons/WhiteSur-dark/apps@2x/scalable/bluetooth.svg" "Bluetooth Disconnected" "Realme Buds disconnected successfully!"
}

# Main execution flow
main() {
    if ! check_bluetooth; then
        return 1
    fi

    if ! disconnect_bluetooth; then
        return 1
    fi
}

main
