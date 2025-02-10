#!/bin/bash
while true; do
    read -rsn1 key
    if [[ $key == $'\e' ]]; then
        eww close-all
    fi
done

