#!/bin/bash
# Simple script to launch Greenclip through Rofi

# Ensure the Wayland environment variable is set (if needed)

# Launch Rofi with Greenclip clipboard mode
rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'
