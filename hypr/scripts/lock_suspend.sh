#!/bin/bash

set -euo pipefail

# Function to check if the system is already suspended
is_suspended() {
    [[ "$(systemctl is-system-running 2>/dev/null)" == "suspended" ]]
}

# Function to lock the screen
lock_screen() {
    if ! command -v hyprlock >/dev/null 2>&1; then
        printf "Error: hyprlock not found. Exiting.\n" >&2
        return 1
    fi
    hyprlock
}

# Function to suspend the system
suspend_system() {
    if ! systemctl suspend; then
        printf "Error: Failed to suspend the system.\n" >&2
        exit 1
    fi
}

main() {
    if is_suspended; then
        exit 0
    fi

    if ! lock_screen; then
        printf "Warning: Screen lock failed, proceeding to suspend.\n" >&2
    fi

    suspend_system
}

main "$@"
