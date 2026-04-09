#!/bin/bash
# Bluetooth Device MAC Address (Update this with your device's MAC)
BT_DEVICE_MAC="98:47:44:77:AA:AA"

# Function to check if the device is already connected
is_device_connected() {
    local status
    status=$(bluetoothctl info "$BT_DEVICE_MAC" 2>/dev/null | grep -i "Connected" | awk '{print $2}')
    [[ "$status" == "yes" ]]
}

# Function to connect to Bluetooth device
connect_bluetooth() {
    sleep 0.5
    if bluetoothctl connect "$BT_DEVICE_MAC"; then
        echo "Realme Buds connected successfully!"
    else
        echo "Failed to connect to Realme Buds."
    fi
}

# Function to disconnect from Bluetooth device
disconnect_bluetooth() {
    if bluetoothctl disconnect "$BT_DEVICE_MAC"; then
        echo "Realme Buds disconnected successfully!"
    else
        echo "Failed to disconnect from Realme Buds."
    fi
}

# Main execution flow
if is_device_connected; then
    disconnect_bluetooth
else
    connect_bluetooth
fi
