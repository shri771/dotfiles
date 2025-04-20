#!/usr/bin/env bash

DEVICE_MAC="98:47:44:77:AA:AA"
COLOR="#ba5663"
COLOR_ALERT="#ff1d61"
ICON_HEADPHONE="  "

# 11 battery level icons
BLOCKS=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)

get_vert_bar() {
  local pct=$1
  local idx=$(( pct * (${#BLOCKS[@]} - 1) / 100 ))
  (( idx < 0 )) && idx=0
  (( idx >= ${#BLOCKS[@]} )) && idx=$((${#BLOCKS[@]} - 1))
  echo "${BLOCKS[idx]}"
}

if bluetoothctl info "$DEVICE_MAC" | grep -q "Connected: yes"; then
  # Initial battery fetch
  batt=$(upower -d | awk "/$DEVICE_MAC/,/^$/" | grep -i percentage | awk '{print $2}')
  
  # If battery info is empty — wait and retry (up to 3 times)
  retries=3
  while [[ -z $batt && $retries -gt 0 ]]; do
    sleep 0.5
    batt=$(upower -d | awk "/$DEVICE_MAC/,/^$/" | grep -i percentage | awk '{print $2}')
    ((retries--))
  done

  if [[ -z $batt ]]; then
    pct=0
    label="??%"
  else
    pct=${batt%\%}
    label="$pct%"
  fi

  (( pct <= 10 )) && use_color="$COLOR_ALERT" || use_color="$COLOR"
  bar=$(get_vert_bar "$pct")

  echo "%{F$use_color}%{T1}$ICON_HEADPHONE%{T-} %{T2}$bar%{T-} %{T1}$label%{T-}%{F-}"
else
  echo "%{F$COLOR}%{T1}$ICON_HEADPHONE%{T-}%{F-}"
fi
i
