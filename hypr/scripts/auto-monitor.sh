#!/usr/bin/env bash
# /home/sh/dotfiles/hypr/scripts/auto-monitor.sh
LOG=/tmp/auto-monitor.log
echo "$(date -Iseconds) called with $1" >>"$LOG"

sleep 1

MONS=$(hyprctl monitors)

if echo "$MONS" | grep -q "HDMI-A-1"; then
    hyprctl keyword monitor "HDMI-A-1, preferred, auto, 1"
    hyprctl keyword monitor "eDP-1, disable"
else
    hyprctl keyword monitor "eDP-1, preferred, auto, 1"
fi
