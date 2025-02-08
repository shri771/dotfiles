#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Brightness levels (adjust as needed)
DAY_BRIGHTNESS=90
NIGHT_BRIGHTNESS=40
FAST_STEP=6     # Step increase/decrease for fast transition
SLOW_STEP=6     # Step increase/decrease for slow transition
FAST_DELAY=0.1  # Delay in seconds for fast transition
SLOW_DELAY=0.1  # Delay in seconds for slow transition

# Path to brightness control
BRIGHTNESS_PATH="/sys/class/backlight/intel_backlight/brightness"
MAX_BRIGHTNESS_PATH="/sys/class/backlight/intel_backlight/max_brightness"

# Ensure brightness files exist
if [[ ! -f "$BRIGHTNESS_PATH" || ! -f "$MAX_BRIGHTNESS_PATH" ]]; then
    printf "Error: Brightness control files not found.\n" >&2
    exit 1
fi

# Get max brightness value
get_max_brightness() {
    local max_brightness
    if ! max_brightness=$(cat "$MAX_BRIGHTNESS_PATH" 2>/dev/null); then
        printf "Error: Unable to read max brightness.\n" >&2
        exit 1
    fi
    printf "%d" "$max_brightness"
}

# Get current brightness value
get_current_brightness() {
    local current_brightness
    if ! current_brightness=$(cat "$BRIGHTNESS_PATH" 2>/dev/null); then
        printf "Error: Unable to read current brightness.\n" >&2
        exit 1
    fi
    printf "%d" "$current_brightness"
}

# Convert percentage to brightness value
convert_percentage_to_brightness() {
    local percent="$1"
    local max_brightness; max_brightness=$(get_max_brightness)
    printf "%d" $(( max_brightness * percent / 100 ))
}

# Set brightness smoothly
set_brightness_smoothly() {
    local target_percent="$1"
    local transition_type="$2"  # "fast" or "slow"
    
    local step delay
    if [[ "$transition_type" == "fast" ]]; then
        step="$FAST_STEP"
        delay="$FAST_DELAY"
    else
        step="$SLOW_STEP"
        delay="$SLOW_DELAY"
    fi

    local current_brightness; current_brightness=$(get_current_brightness)
    local target_brightness; target_brightness=$(convert_percentage_to_brightness "$target_percent")

    while (( current_brightness != target_brightness )); do
        if (( current_brightness < target_brightness )); then
            current_brightness=$(( current_brightness + (step * $(get_max_brightness) / 100) ))
            (( current_brightness > target_brightness )) && current_brightness="$target_brightness"
        else
            current_brightness=$(( current_brightness - (step * $(get_max_brightness) / 100) ))
            (( current_brightness < target_brightness )) && current_brightness="$target_brightness"
        fi

        if ! printf "%d" "$current_brightness" | sudo tee "$BRIGHTNESS_PATH" >/dev/null; then
            printf "Error: Failed to set brightness.\n" >&2
            exit 1
        fi

        sleep "$delay"
    done
}

# Determine time-based brightness
adjust_brightness() {
    local hour; hour=$(date +%H)
    hour=$((10#$hour))  # Force decimal interpretation to prevent octal issues

    if (( hour >= 7 && hour < 19 )); then
        set_brightness_smoothly "$DAY_BRIGHTNESS" "fast"
    else
        set_brightness_smoothly "$NIGHT_BRIGHTNESS" "slow"
    fi
}

# Execute main function
adjust_brightness

