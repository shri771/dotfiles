#!/bin/bash

BAT=$(cat /sys/class/power_supply/BAT*/capacity)

if [ "$BAT" -ge 90 ]; then ICON=""
elif [ "$BAT" -ge 70 ]; then ICON=""
elif [ "$BAT" -ge 50 ]; then ICON=""
elif [ "$BAT" -ge 30 ]; then ICON=""
else ICON=""
fi

echo "<b> $ICON  $BAT% </b>"
