#!/bin/sh

BAT_PATH="/sys/class/power_supply/BAT0"
# auto-find the AC (mains) supply directory (still used for status only)
for p in /sys/class/power_supply/*; do
  [ -f "$p/type" ] && grep -q "Mains" "$p/type" && AC_PATH="$p"
done

GOV_PATH="/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"

# sanity checks
[ ! -f "$BAT_PATH/charge_now" ] || [ ! -f "$BAT_PATH/charge_full" ] && {
  echo "Battery info not available"
  exit 1
}

charge_now=$(cat "$BAT_PATH/charge_now")
charge_full=$(cat "$BAT_PATH/charge_full")
status=$(cat "$BAT_PATH/status")

[ "$charge_full" -eq 0 ] && {
  echo "Battery info not available"
  exit 1
}

capacity=$(( charge_now * 100 / charge_full ))

icons=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
index=$(( capacity / 10 )); [ "$index" -gt 10 ] && index=10
icon=${icons[$index]}

# color logic
if [ "$capacity" -le 25 ]; then
  COLOR="%{F#ff1d61}"
else
  COLOR="%{F#ffaa7f}"
fi

# bolt if governor is performance (now on both AC and battery)
extra=""
if [ -f "$GOV_PATH" ] && [ "$(cat "$GOV_PATH")" = "performance" ]; then
  extra=" %{F#00ff00}⚡%{F-}"
fi

case "$status" in
  "Charging")
    echo "${COLOR}⚡ ${capacity}%${extra} %{F-}" ;;
  "Full")
    echo "${COLOR}${icon} Full${extra} %{F-}" ;;
  "Not charging")
    echo "${COLOR}${icon} ${capacity}%${extra} %{F-}" ;;
  *)
    echo "${COLOR}${icon} ${capacity}%${extra} %{F-}" ;;
esac
