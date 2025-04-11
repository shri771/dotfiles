#!/bin/bash

# FIFO path
fifo="$HOME/.config/polybar/pulseaudio_fifo"

# Create the FIFO if it doesn't exist
[[ -p "$fifo" ]] || mkfifo "$fifo"

# Listen to pulseaudio events
pactl subscribe | grep --line-buffered "sink" | while read -r _; do
    ~/.config/polybar/scripts/pulseaudio_status.sh > "$fifo"
done
