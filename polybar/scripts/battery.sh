#!/bin/sh

BAT_PATH="/sys/class/power_supply/BAT0"
AC_PATH="/sys/class/power_supply/AC"

# Check for required files
if [ ! -f "$BAT_PATH/charge_now" ] || [ ! -f "$BAT_PATH/charge_full" ]; then
    echo "Battery info not available"
    exit 1
fi

# Read battery values
charge_now=$(cat "$BAT_PATH/charge_now")
charge_full=$(cat "$BAT_PATH/charge_full")
status=$(cat "$BAT_PATH/status")

# Prevent division by zero
if [ "$charge_full" -eq 0 ]; then
    echo "Battery info not available"
    exit 1
fi

# Calculate percentage
capacity=$((charge_now * 100 / charge_full))

# Icons for different capacity levels
icons=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
index=$((capacity / 10))
[ "$index" -gt 10 ] && index=10
icon=${icons[$index]}

# "Rosemery" color variable for Polybar formatting
COLOR="%{F#c17d7d}"

# Determine the format based on status and apply the rosemery color
case "$status" in
    "Charging")
        echo "${COLOR} ${capacity}% ${RESET}"
        ;;
    "Full")
        echo "${COLOR}${icon} Full ${RESET}"
        ;;
    "Not charging")
        echo "${COLOR}󱘖 ${capacity}% ${RESET}"
        ;;
    *)
        echo "${COLOR}${icon} ${capacity}% ${RESET}"
        ;;
esac
