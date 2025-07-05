#!/bin/bash

# --- Configuration ---
TLP_CMD="/usr/bin/tlp"
NOTIFY_CMD="/usr/bin/notify-send"
ICON_PATH="/home/sh/.icons/WhiteSur/apps/scalable/io.github.nate_xyz.Chromatic.svg"
# --- End Configuration ---

echo "Switching to Performance Mode..."
sudo ${TLP_CMD} ac
${NOTIFY_CMD} -i "${ICON_PATH}" "Power Profile" "Switched to Performance Mode"
echo "Done."
