#!/bin/bash

# --- Configuration ---
TLP_CMD="/usr/bin/tlp"
NOTIFY_CMD="/usr/bin/notify-send"
ICON_PATH="/home/sh/.icons/WhiteSur/apps@2x/scalable/battery.svg"
# --- End Configuration ---

echo "Switching to Power-Save Mode..."
echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

echo "Done."