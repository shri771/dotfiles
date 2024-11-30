#!/bin/bash
ACTIVE_WIN=$(xdotool getactivewindow)
xprop -id $ACTIVE_WIN _NET_WM_STATE | grep "_NET_WM_STATE_ABOVE" &>/dev/null

if [ $? -eq 0 ]; then
  # Remove "Always on Top"
  xprop -id $ACTIVE_WIN -remove _NET_WM_STATE_ABOVE
else
  # Set "Always on Top"
  xprop -id $ACTIVE_WIN -f _NET_WM_STATE 32a -set _NET_WM_STATE_ABOVE
fi
##while set -
