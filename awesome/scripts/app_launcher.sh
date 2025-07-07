#!/usr/bin/env bash
#
# app_launcher.sh — A simple Rofi-based application launcher.
# Uses the default Rofi theme, similar to ClipManager.sh.

# If rofi is already running, kill it to allow this new instance to launch.
if pgrep -x rofi >/dev/null; then
    pkill rofi
fi

# Launch rofi in application mode (drun)
# -config: Specify a custom configuration file
# -show drun: Show list of applications from .desktop files
# -i: Case-insensitive search
# -p: Set a custom prompt
rofi -config "/home/sh/dotfiles/rofi/config-launcher.rasi" -show drun -i -p "Launch"
