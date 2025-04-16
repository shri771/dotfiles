#!/usr/bin/env bash

# Exit if not in Awesome/X11
[ "$XDG_SESSION_TYPE" != "x11" ] && exit 0
! pgrep -x awesome >/dev/null && exit 0

# Info lines
battery=$(acpi 2>/dev/null | awk -F', ' '{print $2}')
uptime=$(uptime -p | sed 's/up //')
datetime=$(date '+%a %d %b %Y  %H:%M:%S')

# Take and blur current screen (requires scrot & imagemagick)
scrot /tmp/lock.png
convert /tmp/lock.png -filter Gaussian -resize 10% -resize 1000% /tmp/lock-blur.png

# Run i3lock-color with styling
i3lock \
  --image=/tmp/lock-blur.png --blur 5 \
  --clock --indicator \
  --time-pos="x+0:y+100" \
  --date-pos="x+0:y+160" \
  --greeter-pos="x+0:y+200" \
  --greeter-text="🔋 $battery | ⏱ $uptime" \
  --date-str="$datetime" \
  --time-color=ffffffff --date-color=ffffffff --greeter-color=ffffffff \
  --insidever-color=00000000 --insidewrong-color=00000000 \
  --ring-color=ffffff55 --ringver-color=00ff00ff --ringwrong-color=ff0000ff \
  --line-color=ffffff55 --keyhl-color=ff0000ff \
  --time-font="Monospace" --date-font="Monospace" --greeter-font="Monospace" \
  --time-size=48 --date-size=20 --greeter-size=18
