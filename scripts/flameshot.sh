#!/bin/bash

script --command "QT_QPA_PLATFORM=wayland flameshot gui" /dev/null
# or
bash -c -- "QT_QPA_PLATFORM=wayland flameshot gui"
# or
sh -c -- "QT_QPA_PLATFORM=wayland flameshot gui"
