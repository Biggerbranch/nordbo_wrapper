#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(dirname "$0")"

# Load configs (inklusive ES credentials)
source "$SCRIPT_DIR/config.sh"

# Hent nye ZIP-filer fra cloud
echo "[*] Fetching new ZIPs..."
"$SCRIPT_DIR/fetch_from_cloud.sh"

# Process hver ZIP i download-mappen
shopt -s nullglob
for zipfile in "$DOWNLOAD_DIR"/*.zip; do
    bash "$SCRIPT_DIR/process_zip.sh" "$zipfile" || echo "[WARN] Failed processing $zipfile"
done

echo "[*] All ZIP files processed."
