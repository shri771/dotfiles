#!/usr/bin/env bash

# Define where to save the videos
SAVE_DIR="$HOME/Downloads"
FILENAME="$SAVE_DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mp4"

# Ensure the directory exists
mkdir -p "$SAVE_DIR"

# Check if wf-recorder is already running
if pgrep -x "wf-recorder" > /dev/null; then
    # If it is running, send the interrupt signal to stop and save it safely
    pkill -INT -x wf-recorder
    notify-send "Recording Stopped" "Video saved to $SAVE_DIR"
else
    # If not running, prompt slurp to select a region
    REGION=$(slurp)

    # If you press ESC and cancel slurp, exit the script silently
    if [ -z "$REGION" ]; then
        exit 1
    fi

    # Start recording at 60fps (-r 60) with the selected region (-g)
    notify-send "Recording Started" "Run the script again to stop."
    wf-recorder -g "$REGION" -r 60 -f "$FILENAME"
fi
