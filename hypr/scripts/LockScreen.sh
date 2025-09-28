#!/bin/bash

# Check which display server is running
if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    # Running on Wayland - use hyprlock
    pidof hyprlock || hyprlock -q
elif [ "$XDG_SESSION_TYPE" = "x11" ] || [ -n "$DISPLAY" ]; then
    # Running on X11 - use betterlockscreen
    betterlockscreen --lock
else
    echo "Error: Could not determine display server type"
    exit 1
fi
