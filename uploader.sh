#!/bin/bash

PENDINGDIR="$HOME/nordbo_wrapper/pending"
DONEDIR="$HOME/nordbo_wrapper/done"
GDRIVE_FOLDER_ID="1Y6euOzGfxi5FOqbKYvgdoUXTGies_Ofn"

mkdir -p "$PENDINGDIR" "$DONEDIR"

while true; do
    for zipfile in "$PENDINGDIR"/*.zip; do
        [ -f "$zipfile" ] || continue

        # Flyt filen til done/ før upload
        filename=$(basename "$zipfile")
        donefile="$DONEDIR/$filename"
        mv "$zipfile" "$donefile"

        echo "Uploading $donefile..."
        if rclone copy "$donefile" "gdrive:$GDRIVE_FOLDER_ID" >/dev/null 2>&1; then
            echo "Uploaded $donefile successfully, deleting..."
            rm -f "$donefile"
        else
            echo "Upload failed for $donefile, will retry later"
        fi
    done

    sleep 10
done
