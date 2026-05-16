#!/usr/bin/env bash

# Define where to save the videos
SAVE_DIR="$HOME/Videos/Screan-Recording"
FILENAME="$SAVE_DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mp4"

# Ensure the directory exists
mkdir -p "$SAVE_DIR"

case "$1" in
    --start)
        if pgrep -x "wf-recorder" > /dev/null; then
            notify-send "Already Recording" "Stop the current recording first (SUPER+ALT+R)"
            exit 1
        fi
        REGION=$(slurp)
        if [ -z "$REGION" ]; then
            exit 1
        fi
        notify-send "Recording Started" "Press SUPER+ALT+R to stop."
        wf-recorder -g "$REGION" -r 60 -f "$FILENAME"
        ;;
    --stop)
        if pgrep -x "wf-recorder" > /dev/null; then
            pkill -INT -x wf-recorder
            notify-send "Recording Stopped" "Video saved to $SAVE_DIR"
        else
            notify-send "No Recording" "No active recording to stop."
        fi
        ;;
    *)
        # Toggle behavior (backward compat)
        if pgrep -x "wf-recorder" > /dev/null; then
            pkill -INT -x wf-recorder
            notify-send "Recording Stopped" "Video saved to $SAVE_DIR"
        else
            REGION=$(slurp)
            if [ -z "$REGION" ]; then
                exit 1
            fi
            notify-send "Recording Started" "Run the script again to stop."
            wf-recorder -g "$REGION" -r 60 -f "$FILENAME"
        fi
        ;;
esac
