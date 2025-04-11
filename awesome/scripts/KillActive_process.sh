#!/bin/bash

# Get the window ID of the currently focused window
wid=$(xdotool getactivewindow)

# Get the PID of the window
pid=$(xprop -id "$wid" _NET_WM_PID | awk '{ print $3 }')

# Kill the process
if [[ -n "$pid" ]]; then
  kill "$pid"
fi
