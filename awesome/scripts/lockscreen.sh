#!/usr/bin/env bash

# 1) grab & blur
scrot /tmp/lock.png
magick convert /tmp/lock.png -blur 0x6 /tmp/lock_blur.png

# 2) time & date
TIME="$(date +'%H:%M')"
DATE="$(date +'%A, %d %B %Y')"

# 3) overlay onto blurred image
magick convert /tmp/lock_blur.png \
    -font DejaVu-Sans-Bold -fill white \
    -gravity North -pointsize 90 -annotate +0+120 "$TIME" \
    -gravity North -pointsize 30 -annotate +0+220 "$DATE" \
    -fill 'rgba(255,255,255,0.2)' \
    -draw "roundrectangle 700,900 1180,980 25,25" \
    /tmp/lock_final.png

# 4) call stock i3lock
i3lock \
    -n \               # don’t fork
-i /tmp/lock_final.png # set our image
