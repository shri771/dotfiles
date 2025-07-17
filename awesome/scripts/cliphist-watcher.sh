#!/bin/bash
#
# cliphist-watcher.sh - An X11 clipboard watcher for cliphist.
#
# This script uses 'clipnotify' to wait for changes to the X11 clipboard
# and then uses 'xclip' to read the content and store it with 'cliphist'.
# This provides a functional equivalent to the Wayland-based 'wl-paste --watch' command.

# Ensure the required tools are installed before starting.
if ! command -v clipnotify >/dev/null || ! command -v xclip >/dev/null; then
    notify-send "Cliphist Watcher Error" "Please install 'clipnotify' and 'xclip' to use this script."
    exit 1
fi

# Loop indefinitely to keep watching the clipboard.
while clipnotify; do
    # When clipnotify detects a change, check available formats (targets).
    targets=$(xclip -o -selection clipboard -t TARGETS)

    # Prioritize storing images if available, otherwise store as text.
    if echo "$targets" | grep -q "image/png"; then
        xclip -o -selection clipboard -t image/png | cliphist store -max-items 500
    elif echo "$targets" | grep -q "image/jpeg"; then
        xclip -o -selection clipboard -t image/jpeg | cliphist store -max-items 500
    else
        # Fallback to storing standard text.
        xclip -o -selection clipboard | cliphist store -max-items 500
    fi
done
