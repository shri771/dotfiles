#!/bin/bash

# Exit if not in an X11 session
if [ "$XDG_SESSION_TYPE" != "x11" ]; then
    exit 0
fi


i3lock \
  --force-clock \
  --time-str="%H:%M:%S  %A, %d %b" \
  --verif-text="Verifying..." \
  --wrong-text="Wrong!" \
  --noinput-text="..." \
  --greeter-text="🔒  Locked – enter password" \
  --greeter-font="Fira Sans" \
  --greeter-color=FFFFFF \
  --time-color=FFFFFF \
  --inside-color=282A36 \
  --ring-color=FF79C6 \
  --separator-color=44475A \
  --keyhl-color=FF5555 \
  --bshl-color=FF5555 \
  --radius=120 \
  --shadow-color=000000 \
  --greeter-shadow-color=000000 \
  --indicator \
  --image="$HOME/.config/betterlockscreen/backgrounds/lock.jpg" \
  --blur=0 \
  --pixelate=20
