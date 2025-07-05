#!/bin/bash

# --- Configuration ---
COMPOSE_FILE="/home/sh/Docker/Con/homeAssistant/compose.yaml"
ICON_PATH="/home/sh/.icons/WhiteSur/apps@2x/scalable/homebank.svg"

# --- Absolute paths to commands ---
DOCKER_CMD="/usr/bin/docker"
NOTIFY_CMD="/usr/bin/notify-send"
# --- End Configuration ---

echo "Stopping Home Assistant..."
${NOTIFY_CMD} -i "${ICON_PATH}" "Home Assistant" "Stopping container..."
${DOCKER_CMD} compose -f "${COMPOSE_FILE}" down
echo "Home Assistant stopped."
${NOTIFY_CMD} -i "${ICON_PATH}" "Home Assistant" "Container stopped."
exit 0
