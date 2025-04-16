#!/bin/bash

DASHBOARD_FLAG="$HOME/.cache/eww_launch.dashboard"
MUSIC_SCRIPT="$HOME/.config/eww/scripts/music_info"

[[ ! -f "$DASHBOARD_FLAG" ]] && exit 0

case "$1" in
    next)
        "$MUSIC_SCRIPT" --next
        ;;
    prev)
        "$MUSIC_SCRIPT" --prev
        ;;
    *)
        exit 1
        ;;
esac
