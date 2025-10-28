#!/bin/sh

LOG_FILE="/tmp/gnome-keyring-startup.log"
echo "--- Script started at $(date) ---" > "$LOG_FILE"

# Log current environment for debugging
echo "Initial environment:" >> "$LOG_FILE"
env >> "$LOG_FILE"
echo "--------------------" >> "$LOG_FILE"

# Start the daemon and capture its output
echo "Starting gnome-keyring-daemon..." >> "$LOG_FILE"
keyring_output=$(gnome-keyring-daemon --start)
echo "Daemon output: [$keyring_output]" >> "$LOG_FILE"

# Check if it started correctly and produced output
if [ -n "$keyring_output" ]; then
  # Export the variables within this script's environment
  eval "$keyring_output"
  export GNOME_KEYRING_CONTROL
  export SSH_AUTH_SOCK

  echo "Variables exported in script:" >> "$LOG_FILE"
  echo "GNOME_KEYRING_CONTROL=$GNOME_KEYRING_CONTROL" >> "$LOG_FILE"
  echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> "$LOG_FILE"

  # Update the systemd and D-Bus activation environment
  echo "Updating D-Bus environment..." >> "$LOG_FILE"
  dbus-update-activation-environment --systemd GNOME_KEYRING_CONTROL SSH_AUTH_SOCK >> "$LOG_FILE" 2>&1
  echo "D-Bus update command finished." >> "$LOG_FILE"
else
  echo "gnome-keyring-daemon produced no output." >> "$LOG_FILE"
fi

echo "--- Script finished at $(date) ---" >> "$LOG_FILE"
