#!/bin/bash

# Ensure arguments are passed
if [ $# -ne 1 ]; then
    echo "Usage: $0 x,y"
    exit 1
fi

# Parse input arguments (expects format "X,Y")
IFS=',' read -r X_POS Y_POS <<< "$1"

# Get screen resolution dynamically
SCREEN_WIDTH=1920
SCREEN_HEIGHT=1200

# Calculate percentages and round them
X_PERCENT=$(awk "BEGIN {print int( ($X_POS / $SCREEN_WIDTH) * 100 + 0.5 ) }")
Y_PERCENT=$(awk "BEGIN {print int( ($Y_POS / $SCREEN_HEIGHT) * 100 + 0.5 ) }")

# Output in "X% Y%" format
echo "$X_PERCENT% $Y_PERCENT%"
