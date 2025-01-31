#!/usr/bin/env bash
# Script to get system uptime in a human-readable format

if [[ -r /proc/uptime ]]; then
    s=$(< /proc/uptime)
    s=${s/.*}
else
    echo "Error UptimeNixOS.sh: Uptime could not be determined." >&2
    exit 1
fi

d=$((s / 60 / 60 / 24))
h=$((s / 60 / 60 % 24))
m=$((s / 60 % 60))

# Convert to human-readable format
uptime=""
if ((d > 0)); then
    uptime+="$d days"
    ((h > 0)) && uptime+=", $h hours"
elif ((h > 0)); then
    uptime+="$h hours"
fi
if ((d == 0 && h == 0)); then
    uptime+="$m minutes"
fi

# Trim trailing comma and space
uptime=${uptime%', '}

echo "Uptime $uptime"
