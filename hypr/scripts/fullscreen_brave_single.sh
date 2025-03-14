#!/bin/bash

# Ensure XDG_RUNTIME_DIR is set correctly
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Find the actual Hyprland socket
HYPR_SOCKET=$(find "$XDG_RUNTIME_DIR/hypr/" -name "*.socket.sock" 2>/dev/null | head -n 1)

# If no socket is found, exit with an error
if [[ ! -S "$HYPR_SOCKET" ]]; then
    printf "Error: Hyprland socket not found. Ensure Hyprland is running.\n" >&2
    exit 1
fi

printf "Debug: Hyprland socket found at %s. Continuing execution...\n" "$HYPR_SOCKET"

# Function to check if the active window is Brave or Kitty and not fullscreen
is_valid_window() {
    local active_window
    local fullscreen
    local window_info

    # Get raw active window JSON data
    window_info=$(hyprctl activewindow -j 2>&1)
    printf "Debug: Raw active window data = %s\n" "$window_info"

    # Check if we received valid JSON
    if ! echo "$window_info" | jq empty >/dev/null 2>&1; then
        printf "Error: Invalid JSON received from hyprctl.\n" >&2
        return 1
    fi

    # Extract window class
    active_window=$(echo "$window_info" | jq -r '.class' 2>/dev/null)
    if [[ -z "$active_window" || "$active_window" == "null" ]]; then
        printf "Error: Could not retrieve active window class.\n" >&2
        return 1
    fi
    printf "Debug: Active window class = '%s'\n" "$active_window"

    # Extract fullscreen status
    fullscreen=$(echo "$window_info" | jq -r '.fullscreen' 2>/dev/null)
    if [[ -z "$fullscreen" || "$fullscreen" == "null" ]]; then
        printf "Error: Could not retrieve fullscreen status.\n" >&2
        return 1
    fi
    printf "Debug: Fullscreen status = '%s'\n" "$fullscreen"

    # Check if it's Brave or Kitty and not fullscreen
    if { [[ "$active_window" == "Brave-browser" ]] || [[ "$active_window" == "kitty" ]]; } && [[ "$fullscreen" == "false" ]]; then
        printf "Debug: Valid window detected: %s (Not fullscreen).\n" "$active_window"
        return 0
    else
        printf "Debug: Condition not met. Skipping shortcut triggers.\n"
        return 1
    fi
}

# Function to trigger Ctrl+P and ModKey+Space using ydotool
trigger_shortcuts() {
    printf "Debug: Triggering Ctrl+P...\n"
    ydotool key 29:1 25:1 25:0 29:0  # Press and release Ctrl+P
    sleep 0.1  # Short delay
    printf "Debug: Triggering ModKey+Space...\n"
    ydotool key 125:1 57:1 57:0 125:0  # Press and release ModKey + Space
}

# Ensure ydotool is running
if ! pgrep -x "ydotoold" >/dev/null; then
    printf "Error: ydotoold is not running. Start it with 'sudo ydotoold' first.\n" >&2
    exit 1
fi

# Debugging output before checking the condition
printf "Debug: Checking if Brave or Kitty is the active window and not in fullscreen...\n"

# Check if Brave or Kitty is active and not fullscreen, then trigger shortcuts
if is_valid_window; then
    trigger_shortcuts
else
    printf "Debug: No action taken.\n"
fi
