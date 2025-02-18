#!/bin/sh

for i in {5..6}; do
    temp=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon$i/temp1_input 2>/dev/null)
    
    if [ -n "$temp" ] && [ "$temp" -eq "$temp" ] 2>/dev/null; then
        if [ "$temp" -eq 28000 ]; then
            continue
        else
            ln -sf "/sys/devices/platform/coretemp.0/hwmon/hwmon$i/temp1_input" "$HOME/.config/hypr/scripts/temp_sensor"
            exit 0
        fi
    fi
done

# Default to hwmon5 if no valid sensor is found
ln -sf "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input" "$HOME/.config/hypr/scripts/temp_sensor"
