#!/bin/bash

# Configuration
BATTERY_PATH="/sys/class/power_supply/BAT0"
NOTIFIER="/usr/bin/notify-send"
ICON_BASE="battery-level"

# Environment setup for GUI access
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# Get battery status
get_battery_status() {
    echo "$(( $(<"$BATTERY_PATH/capacity") ))|$(<"$BATTERY_PATH/status")"
}

# Get appropriate battery icon
get_icon() {
    local level=$1
    local status=$2
    local icon_level=$(( (level + 5) / 10 * 10 ))  # Round to nearest 10%
    
    if [ "$status" = "Charging" ]; then
        echo "battery-charging-symbolic"
    else
        echo "$ICON_BASE-$icon_level-symbolic"
    fi
}

# Send notification
send_notification() {
    local urgency="$1"
    local icon="$2"
    local title="$3"
    local message="$4"
    
    "$NOTIFIER" \
        -u "$urgency" \
        -i "$icon" \
        "$title" \
        "$message"
}

# Main logic
IFS='|' read -r capacity status < <(get_battery_status)
icon=$(get_icon "$capacity" "$status")

if [ "$status" = "Discharging" ]; then
    case $capacity in
        10)
            send_notification "critical" "$icon" \
                "Battery Warning" "10% remaining - Connect charger!"
            ;;
        6)
            send_notification "critical" "$icon" \
                "Battery Critical" "6% remaining - Connect charger immediately!"
            ;;
    esac
fi
