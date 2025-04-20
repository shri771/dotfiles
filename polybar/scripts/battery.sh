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

# Color logic: red if <= 25%, else rosemery
if [ "$capacity" -le 25 ]; then
    COLOR="%{F#ff1d61}"  # Red for low battery
else
    COLOR="%{F#ffaa7f}"  # Normal rosemery color
fi

# Determine output based on status
case "$status" in
    "Charging")
        echo "${COLOR} ${capacity}% %{F-}"
        ;;
    "Full")
        echo "${COLOR}${icon} Full %{F-}"
        ;;
    "Not charging")
        echo "${COLOR}󱘖 ${capacity}% %{F-}"
        ;;
    *)
        echo "${COLOR}${icon} ${capacity}% %{F-}"
        ;;
esac
