#!/bin/bash
# Minimize the currently focused window
wmctrl -r ":ACTIVE:" -b add,hidden
