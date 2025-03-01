#!/bin/bash

echo -e "\033[1;36m🚀 Starting Zypper installation... \033[0m"
echo -ne '⏳ Installing [                    ] (0%)\r'
sleep 1
zypper install -y $1 &
PID=$!

while kill -0 $PID 2>/dev/null; do
    for i in {1..20}; do
        echo -ne "⏳ Installing [$(
            printf '%.0s=' $(seq 1 $i)
        )$(printf '%.0s ' $(seq $((20 - i))))] ($((i * 5))%)\r"
        sleep 0.2
    done
done

echo -e "\n✅ \033[1;32mInstallation Complete!\033[0m"
