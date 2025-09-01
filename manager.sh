#!/bin/bash

# Start uploader i baggrunden
./uploader.sh &
UPLOADER_PID=$!
echo "Uploader started with PID $UPLOADER_PID"

# Restart-loop
while true; do
    ./run_nordbo.sh "$@"
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        echo "Main program exited normally (code $EXIT_CODE). Stopping uploader..."
        kill $UPLOADER_PID 2>/dev/null
        wait $UPLOADER_PID 2>/dev/null
        exit 0
    else
        echo "Main program crashed (code $EXIT_CODE). Restarting..."
        sleep 2
    fi
done
