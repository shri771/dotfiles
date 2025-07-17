#!/bin/bash

# Bluetooth Device MAC Address (Update this with your device's MAC)
BT_DEVICE_MAC="98:47:44:77:AA:AA"

# Function to check if Bluetooth is enabled
check_bluetooth() {
    if ! systemctl is-active --quiet bluetooth; then
        printf "Error: Bluetooth service is not active.\n" >&2
        notify-send -i "/home/sh/.icons/WhiteSur-dark/apps@2x/scalable/bluetooth.svg" "Bluetooth Error" "Bluetooth service is not active."
        return 1
    fi
}

# Function to check if the device is already connected
is_device_connected() {
    local status
    status=$(bluetoothctl info "$BT_DEVICE_MAC" 2>/dev/null | grep -i "Connected" | awk '{print $2}')
    [[ "$status" == "yes" ]]
}

# Function to connect to Bluetooth device
connect_bluetooth() {
    printf "Waiting 2 seconds before connecting...\n"
    sleep 2

    notify-send -i "/home/sh/.icons/WhiteSur-dark/apps@2x/scalable/bluetooth.svg" "Bluetooth" "Connecting to Realme Buds..."
    printf "Connecting to Bluetooth device %s...\n" "$BT_DEVICE_MAC"
    if ! bluetoothctl connect "$BT_DEVICE_MAC"; then
        printf "Error: Failed to connect to Bluetooth device %s.\n" "$BT_DEVICE_MAC" >&2
        notify-send -i "/home/sh/.icons/WhiteSur-dark/apps@2x/scalable/bluetooth.svg" "Bluetooth Connection Failed" "Failed to connect to Realme Buds."
        return 1
    fi

    printf "Successfully connected to %s.\n" "$BT_DEVICE_MAC"
    notify-send -i "/home/sh/.icons/WhiteSur-dark/apps@2x/scalable/bluetooth.svg" "Bluetooth Connected" "Realme Buds connected successfully!"
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

    if is_device_connected; then
        disconnect_bluetooth
    else
        connect_bluetooth
    fi
}

main
