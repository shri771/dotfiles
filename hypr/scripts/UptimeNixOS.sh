#!/usr/bin/env bash
# Script to get system uptime in a human-readable format

if [[ -r /proc/uptime ]]; then
    s=$(< /proc/uptime)
    s=${s/.*}  # Get total uptime in seconds
else
    echo "Error: Uptime could not be determined." >&2
    exit 1
fi

# Calculate days, hours, and minutes
d=$((s / 86400))  # Days
h=$(( (s % 86400) / 3600 ))  # Hours
m=$(( (s % 3600) / 60 ))  # Minutes

# Formatting uptime output correctly
if ((d > 0)); then
    echo "Uptime: $d days $h hours"
elif ((h > 0)); then
    echo "Uptime: $h hours $m minutes"
else
    echo "Uptime: $m minutes"
fi
