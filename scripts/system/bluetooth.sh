#!/bin/bash

# Bluetooth Device ID (Realme Buds Wireless 3)
BT_DEVICE="108"

# Speaker Device ID (Alder Lake PCH-P HD Audio)
SPEAKER_DEVICE="45"

# Check if Bluetooth headset is connected
if wpctl status | grep -q " $BT_DEVICE. Realme Buds Wireless 3"; then
    echo "Bluetooth connected, switching to Realme Buds Wireless 3 (ID: $BT_DEVICE)"
    wpctl set-default $BT_DEVICE
else
    echo "Bluetooth disconnected, switching to Speakers (ID: $SPEAKER_DEVICE)"
    wpctl set-default $SPEAKER_DEVICE
fi

