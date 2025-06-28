#!/usr/bin/env bash
set -euo pipefail

BATTERY_PATH="/sys/class/power_supply/BAT0"
LOCK_SUSPEND_SCRIPT="$HOME/dotfiles/awesome/scripts/lock.sh"
NOTIFIER="notify-send"

# thresholds (in percent)
WARN_THRESHOLD=21
CRIT1_THRESHOLD=11
CRIT2_THRESHOLD=7
SUSPEND_THRESHOLD=6

# icons
ICONS=(
  [100]="battery-full-symbolic"
   [80]="battery-good-symbolic"
   [60]="battery-medium-symbolic"
   [40]="battery-low-symbolic"
   [20]="battery-caution-symbolic"
   [10]="battery-caution-symbolic"
    [0]="battery-empty-symbolic"
)

# Alert icon and style
ALERT_ICON="dialog-warning"
TOKYO_NIGHT_BG="#1a1b26"
TOKYO_NIGHT_FG="#c0caf5"

debug() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$1"; }

get_battery_percentage() {
  cat "$BATTERY_PATH/capacity" 2>/dev/null || {
    echo "Error: cannot read capacity" >&2
    return 1
  }
}

get_battery_status() {
  cat "$BATTERY_PATH/status" 2>/dev/null || {
    echo "Error: cannot read status" >&2
    return 1
  }
}

battery_icon_for() {
  local lvl=$1
  for threshold in 100 80 60 40 20 10 0; do
    if (( lvl >= threshold )); then
      echo "${ICONS[$threshold]}"
      return
    fi
  done
}

send_notification() {
  # $1=title, $2=body, $3=icon
  $NOTIFIER -u critical -i "$3" \
    -h string:bgcolor:"$TOKYO_NIGHT_BG" \
    -h string:fgcolor:"$TOKYO_NIGHT_FG" \
    "$1" "$2"
}

main() {
  local level status icon
  level=$(get_battery_percentage) || exit 1
  status=$(get_battery_status)    || exit 1

  debug "Level: $level%, Status: $status"

  if [[ "$status" == "Discharging" ]]; then
    icon=$(battery_icon_for "$level")

    if (( level < SUSPEND_THRESHOLD )); then
      debug "< $SUSPEND_THRESHOLD%: suspending."
      send_notification "Battery Critical" "Battery at ${level}%! Suspending now!" "$ALERT_ICON"
      bash "$LOCK_SUSPEND_SCRIPT"
    elif (( level < CRIT2_THRESHOLD )); then
      debug "< $CRIT2_THRESHOLD%: critical alert."
      send_notification "Battery Critical" "Battery at ${level}%! System will suspend soon!" "$ALERT_ICON"
    elif (( level < CRIT1_THRESHOLD )); then
      debug "< $CRIT1_THRESHOLD%: high priority warning."
      send_notification "Battery Critical" "Battery at ${level}%! Please plug in charger!" "$ALERT_ICON"
    elif (( level < WARN_THRESHOLD )); then
      debug "< $WARN_THRESHOLD%: warning."
      send_notification "Battery Warning" "Battery at ${level}%! Connect charger!" "$ALERT_ICON"
    fi
  else
    debug "Battery not discharging; skipping notification."
  fi
}

main "$@"
