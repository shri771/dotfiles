#!/bin/bash

# Ensure DISPLAY is set for GUI applications
export DISPLAY=:0

# Open GNOME Terminal in a new window
gnome-terminal &

# Log the action (optional)
echo "Opened GNOME Terminal at $(date)" >> /tmp/gnome_terminal_open.log

