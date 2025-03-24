#!/bin/bash

# Get all CPU frequencies in one read
freqs=$(cat /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq 2>/dev/null)

# Check if we got any frequencies
if [ -z "$freqs" ]; then
    echo "Error: Could not read CPU frequencies"
    exit 1
fi

# Calculate average frequency using awk
echo "$freqs" | awk '
{
    sum += $1
    count++
}
END {
    if (count > 0) {
        printf "%.2f", (sum / count) / 1000000
    } else {
        print "Error: No CPU frequency data found"
        exit 1
    }
}'
