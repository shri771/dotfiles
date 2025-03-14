#!/bin/bash

set -euo pipefail

# Find the Hyprland instance signature dynamically
if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    HYPRLAND_INSTANCE_SIGNATURE=$(find /tmp/hypr/ -type d -name "instance_*" 2>/dev/null | head -n 1 | awk -F'/' '{print $3}')
fi

# Validate the instance signature
if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    printf "Error: Hyprland instance signature not found. Is Hyprland running?\n"
    exit 1
fi

# Find the correct socket
SOCKET_BASE="/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}"
if [[ -S "$SOCKET_BASE/.socket2.sock" ]]; then
    SOCKET_PATH="$SOCKET_BASE/.socket2.sock"
elif [[ -S "$SOCKET_BASE/.socket.sock" ]]; then
    SOCKET_PATH="$SOCKET_BASE/.socket.sock"
else
    printf "Error: No valid Hyprland socket found in %s\n" "$SOCKET_BASE"
    exit 1
fi

toggle_waybar() {
    pkill -SIGUSR1 waybar  # Toggle hide/show
}

show_waybar() {
    pkill -SIGUSR2 waybar  # Show Waybar while holding
}

listen_for_keypress() {
    socat -u UNIX-CONNECT:"$SOCKET_PATH" - | while read -r event; do
        if echo "$event" | grep -q "keyboard"; then
            if echo "$event" | grep -q "key_pressed, E"; then
                show_waybar  # Show Waybar while holding
            elif echo "$event" | grep -q "key_released, E"; then
                toggle_waybar  # Hide Waybar on release
                break
            fi
        fi
    done
}

listen_for_keypress
