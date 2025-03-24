#!/bin/bash

set -o pipefail

BATTERY_PATH="/sys/class/power_supply/BAT0"
LOCK_SUSPEND_SCRIPT="/home/sh/dotfiles/hypr/scripts/lock_suspend.sh"
NOTIFIER="notify-send"

BATTERY_ICON_CRITICAL="battery-empty-symbolic"
BATTERY_ICON_WARNING="battery-caution-symbolic"

# Battery level icons
BATTERY_ICON_100="battery-full-symbolic"
BATTERY_ICON_80="battery-good-symbolic"
BATTERY_ICON_60="battery-medium-symbolic"
BATTERY_ICON_40="battery-low-symbolic"
BATTERY_ICON_20="battery-caution-symbolic"
BATTERY_ICON_10="battery-empty-symbolic"

get_battery_percentage() {
    local percent
    if ! percent=$(cat "$BATTERY_PATH/capacity" 2>/dev/null); then
        printf "Error: Unable to read battery capacity\n" >&2
        return 1
    fi
    printf "%d" "$percent"
}

get_battery_status() {
    local status
    if ! status=$(cat "$BATTERY_PATH/status" 2>/dev/null); then
        printf "Error: Unable to read battery status\n" >&2
        return 1
    fi
    printf "%s" "$status"
}

get_battery_icon() {
    local level=$1
    if (( level >= 90 )); then
        echo "$BATTERY_ICON_100"
    elif (( level >= 70 )); then
        echo "$BATTERY_ICON_80"
    elif (( level >= 50 )); then
        echo "$BATTERY_ICON_60"
    elif (( level >= 30 )); then
        echo "$BATTERY_ICON_40"
    elif (( level >= 10 )); then
        echo "$BATTERY_ICON_20"
    else
        echo "$BATTERY_ICON_10"
    fi
}

send_notification() {
    local level=$1
    local message=$2
    local icon=$3
    "$NOTIFIER" -u critical -i "$icon" "$level" "<b>󰁹 $message</b>"
}

check_battery() {
    local battery_level battery_status battery_icon
    if ! battery_level=$(get_battery_percentage); then
        return 1
    fi

    if ! battery_status=$(get_battery_status); then
        return 1
    fi

    battery_icon=$(get_battery_icon "$battery_level")

    if [[ "$battery_status" != "Discharging" ]]; then
        return 0
    fi

    case "$battery_level" in
        10)
            send_notification "Battery Warning" "Battery at 10%! Connect charger!" "$battery_icon"
            ;;
        6)
            send_notification "Battery Critical" "Battery at 6%! System will suspend at 5%!" "$battery_icon"
            ;;
        5)
            send_notification "Battery Critical" "Battery at 5%! Suspending now!" "$battery_icon"
            ;;
    esac
}

manual_override() {
    local override_level=$1
    if ! [[ "$override_level" =~ ^[0-9]+$ ]]; then
        printf "Error: Invalid override level\n" >&2
        return 1
    fi

    local battery_status battery_icon
    if ! battery_status=$(get_battery_status); then
        return 1
    fi

    battery_icon=$(get_battery_icon "$override_level")

    if [[ "$battery_status" != "Discharging" ]]; then
        return 0
    fi

    case "$override_level" in
        10)
            send_notification "Battery Warning (Override)" "Battery at 10%! Connect charger!" "$battery_icon"
            ;;
        6)
            send_notification "Battery Critical (Override)" "Battery at 6%! System will suspend at 5%!" "$battery_icon"
            ;;
        5)
            send_notification "Battery Critical (Override)" "Battery at 5%! Suspending now!" "$battery_icon"
            "$LOCK_SUSPEND_SCRIPT"
            ;;
    esac
}

main() {
    if [[ "$1" == "-x" && -n "$2" ]]; then
        manual_override "$2"
    else
        check_battery
    fi
}

main "$@"
