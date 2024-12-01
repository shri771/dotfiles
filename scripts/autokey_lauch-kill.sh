#!/bin/bash

# Launch the application in the background
autokey-gtk -c &

# Get the process ID of the last background process
APP_PID=$!

# Wait for 1 second
sleep 3

# Kill the application
kill $APP_PID
