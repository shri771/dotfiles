#!/bin/bash

# Check if running inside Hyprland
if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "This script must be run inside Hyprland."
    exit 1
fi

# Check if Dolphin is running
if ! hyprctl clients | grep -q "class: dolphin"; then
    echo "Dolphin is not running."
    exit 1
fi

# Extract current Dolphin directory from window title
dolphin_path=$(hyprctl activewindow -j | jq -r '.title' | awk -F' — ' '{print $NF}')

if [[ ! -d "$dolphin_path" ]]; then
    echo "Failed to determine Dolphin's directory."
    exit 1
fi

# Check if Tmux session exists
if tmux has-session -t cn 2>/dev/null; then
    tmux new-window -t cn -n Terminal -c "$dolphin_path"
else
    tmux new-session -s cn -n Terminal -c "$dolphin_path" -d
fi

# Attach to the session
tmux attach-session -t cn
