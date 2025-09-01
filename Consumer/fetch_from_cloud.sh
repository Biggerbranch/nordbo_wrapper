#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/config.sh"

echo "[INFO] Fetching new ZIP files from cloud: $CLOUD_REMOTE"

# Tjek cloud folder
if ! rclone lsd "$CLOUD_REMOTE" >/dev/null 2>&1; then
    echo "[ERROR] CLOUD_REMOTE '$CLOUD_REMOTE' findes ikke eller kan ikke tilgås!"
    exit 1
fi

# Hent kun nye ZIP-filer
rclone copy "$CLOUD_REMOTE" "$DOWNLOAD_DIR" --include "*.zip" --ignore-existing --log-file "$LOGDIR/rclone.log" --log-level INFO

ZIP_COUNT=$(ls -1q "$DOWNLOAD_DIR"/*.zip 2>/dev/null | wc -l)
echo "[INFO] Fetched $ZIP_COUNT ZIP file(s) into $DOWNLOAD_DIR"
