#!/bin/bash
dbus-monitor "interface='org.freedesktop.Notifications'" |
  while read -r line; do
    if echo "$line" | grep -q "flameshot"; then
      echo "Blocked Flameshot notification: $line"
    else
      echo "$line"
    fi
  done
