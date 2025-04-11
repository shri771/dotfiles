#!/bin/bash

muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

if [ "$muted" = "yes" ]; then
    echo ""  # Muted mic icon
else
    echo ""  # Active mic icon
fi
