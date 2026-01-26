#!/usr/bin/env bash

# Get the PID of the active window using JSON output (More reliable on NixOS)
active_pid=$(hyprctl activewindow -j | jq '.pid')

# Check if a valid PID was found (prevents errors if no window is active)
if [ "$active_pid" != "null" ] && [ "$active_pid" -gt 0 ]; then
    # Send SIGKILL (Force Kill) to the process
    kill -9 "$active_pid"

    # Optional: Send a notification
    notify-send "Annihilated" "Process $active_pid has been force killed."
fi
