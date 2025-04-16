#!/bin/bash

DEVICE_MAC="98:47:44:77:AA:AA"
ICON_DISCONNECTED="  "
COLOR="#ba5663"

# Check if device is connected
if bluetoothctl info "$DEVICE_MAC" | grep -q "Connected: yes"; then
    # Try to get battery percentage
    battery=$(upower -d | awk "/$DEVICE_MAC/,/^$/" | grep -i "percentage" | awk '{print $2}')
    
    # Fallback if battery not found
    if [ -z "$battery" ]; then
        echo "%{F$COLOR}$ICON_DISCONNECTED%{F-}"
    else
        echo "%{F$COLOR}$ICON_DISCONNECTED $battery  %{F-}"
    fi
else
    echo "%{F$COLOR}$ICON_DISCONNECTED%{F-}"
fi
