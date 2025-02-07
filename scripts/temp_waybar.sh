
#!/bin/bash
# Find the correct hwmon path for coretemp
hwmon_path=$(find /sys/devices/platform/coretemp.0/hwmon/ -name "temp1_input" | head -n 1)
if [[ -f "$hwmon_path" ]]; then
    cat "$hwmon_path"
else
    echo "N/A" # Fallback in case the path isn't found
fi
