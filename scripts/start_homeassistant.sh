#!/bin/bash

# --- Configuration ---
COMPOSE_FILE="/home/sh/Docker/Con/homeAssistant/compose.yaml"
# IMPORTANT: Change this to the actual service name from your compose.yaml file
CONTAINER_NAME="home-assistant" 
URL="http://localhost:8123/lovelace/0"
ICON_PATH="/home/sh/.icons/WhiteSur/apps@2x/scalable/homebank.svg"

# --- Absolute paths to commands ---
DOCKER_CMD="/usr/bin/docker"
NOTIFY_CMD="/usr/bin/notify-send"
# --- End Configuration ---

# --- Default action: Start container and open browser ---

# Check if the container is running
if ! ${DOCKER_CMD} ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
  echo "Home Assistant is not running. Starting it now..."
  ${NOTIFY_CMD} -i "${ICON_PATH}" "Home Assistant" "Container is not running. Starting it now..."
  ${DOCKER_CMD} compose -f "${COMPOSE_FILE}" up -d
  # Give it a moment to initialize before opening the browser
  sleep 5
else
  echo "Home Assistant is already running."
fi

# Open the URL in Brave
brave "${URL}" &