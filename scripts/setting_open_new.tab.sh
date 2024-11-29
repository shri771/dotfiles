#!/bin/bash

# Ensure DISPLAY is set for GUI applications
export DISPLAY=:0

# Kill any existing GNOME Settings instance
pkill -f gnome-control-center

# Open GNOME Settings in a new window
gnome-control-center &

# Log the action (optional)
echo "Opened GNOME Settings at $(date)" >> /tmp/gnome_settings_open.log

