#!/bin/bash

# Check if xdotool is installed
if ! command -v xdotool &>/dev/null; then
    echo "xdotool is not installed. Please install it using: sudo apt install xdotool"
    exit 1
fi

# Get the active window (for context)
ACTIVE_WINDOW=$(xdotool getactivewindow)

if [[ -z "$ACTIVE_WINDOW" ]]; then
    echo "No active window found. Ensure you're running under X11."
    exit 1
fi

# Simulate Super + Shift + S keypress
xdotool windowactivate "$ACTIVE_WINDOW" key super+shift+s

# Optional: Notify the user (requires notify-send)
if command -v notify-send &>/dev/null; then
    notify-send "Key Simulation" "Super + Shift + S simulated successfully."
fi

