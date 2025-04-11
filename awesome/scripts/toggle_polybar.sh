#!/bin/bash
if xdo id -N Polybar > /dev/null; then
  polybar-msg cmd toggle  # Toggle visibility if supported
  # OR:
  # xdo hide -N Polybar   # Hide
  # xdo show -N Polybar   # Show
else
  polybar -q main &       # Start Polybar if not running
fi
