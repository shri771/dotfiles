#!/bin/bash
# Maximize the currently focused window
wmctrl -r ":ACTIVE:" -b add,maximized_vert,maximized_horz
