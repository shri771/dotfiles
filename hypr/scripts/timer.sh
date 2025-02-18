#!/bin/bash

# Timer script with Rofi interface

# Define the choices
CHOICES="Start Timer\nStart Stopwatch\nExit"

# Ask the user to choose an option
ACTION=$(echo -e "$CHOICES" | rofi -dmenu -p "Choose an action:")

case $ACTION in
    "Start Timer")
        # Ask for the timer duration (in minutes)
        TIMER_DURATION=$(rofi -dmenu -p "Enter timer duration (in minutes):")
        TIMER_DURATION=$((TIMER_DURATION * 60))  # Convert minutes to seconds
        echo "Timer started for $TIMER_DURATION seconds!"
        
        # Start the timer and notify when it finishes
        sleep $TIMER_DURATION && notify-send "Timer finished!"
        ;;
    
    "Start Stopwatch")
        # Start a stopwatch
        START_TIME=$(date +%s)
        while true; do
            CURRENT_TIME=$(date +%s)
            ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
            ELAPSED_FORMATTED=$(printf "%02d:%02d:%02d" $((ELAPSED_TIME / 3600)) $(( (ELAPSED_TIME % 3600) / 60 )) $((ELAPSED_TIME % 60)))
            
            # Display stopwatch time
            STOPWATCH_TIME=$(echo -e "Stopwatch: $ELAPSED_FORMATTED\nStop\n" | rofi -dmenu -p "Running Stopwatch:")
            
            if [[ "$STOPWATCH_TIME" == "Stop" ]]; then
                notify-send "Stopwatch stopped!"
                break
            fi
        done
        ;;
    
    "Exit")
        exit 0
        ;;
    *)
        exit 1
        ;;
esac

