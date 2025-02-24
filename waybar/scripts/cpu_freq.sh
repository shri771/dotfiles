#!/bin/bash
awk '{printf "%.2f\n", $1 / 1000000}' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
