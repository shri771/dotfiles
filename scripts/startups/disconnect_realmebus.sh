#!/bin/bash

# Bluetooth Device MAC Address (Update this with your device's MAC)
BT_DEVICE_MAC="98:47:44:77:AA:AA"

# Function to check if Bluetooth is enabled
check_bluetooth() {
    if ! systemctl is-active --quiet bluetooth; then
        printf "Error: Bluetooth service is not active.\n" >&2
        return 1
    fi
}

# Function to check if the device is already connected
is_device_connected() {
    local status
    status=$(bluetoothctl info "$BT_DEVICE_MAC" 2>/dev/null | grep -i "Connected" | awk '{print $2}')
    [[ "$status" == "yes" ]]
}

# Function to disconnect from Bluetooth device
disconnect_bluetooth() {
    if ! is_device_connected; then
        printf "Device %s is already disconnected.\n" "$BT_DEVICE_MAC"
        return 0
    fi

    printf "Disconnecting from Bluetooth device %s...\n" "$BT_DEVICE_MAC"
    if ! bluetoothctl disconnect "$BT_DEVICE_MAC"; then
        printf "Error: Failed to disconnect from Bluetooth device %s.\n" "$BT_DEVICE_MAC" >&2
        return 1
    fi

    printf "Successfully disconnected from %s.\n" "$BT_DEVICE_MAC"
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
