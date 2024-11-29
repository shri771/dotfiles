#!/bin/bash

# Ensure DISPLAY is set for GUI applications
export DISPLAY=:0

# Open GNOME File Manager (nautilus) in a new window
nautilus --new-window &

# Log the action (optional)
echo "Opened GNOME File Manager in a new window at $(date)" >> /tmp/nautilus_open.log

