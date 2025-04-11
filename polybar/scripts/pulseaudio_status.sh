#!/bin/bash

# Get the default sink name
sink=$(pactl get-default-sink)
vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')
bluetooth=false
if pactl list sinks | grep -A10 "$sink" | grep -qi 'bluez'; then
    bluetooth=true
fi

if [ "$bluetooth" = true ]; then
    icon=""
else
    if [ "$vol" -lt 33 ]; then
        icon=""
    elif [ "$vol" -lt 66 ]; then
        icon=""
    else
        icon=""
    fi
fi

muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
if [ "$muted" = "yes" ]; then
    if [ "$bluetooth" = true ]; then
        echo "󰖁"
    else
        echo "󰖁"
    fi
else
    echo "$icon $vol%"
fi
