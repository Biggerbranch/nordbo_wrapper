#!/bin/bash
set -euo pipefail
shopt -s nullglob  # håndter tomme mønstre
source "$(dirname "$0")/config.sh"

ZIPFILE="$1"
BASENAME=$(basename "$ZIPFILE" .zip)

# TMP-mappe til unzip (unik)
WORK=$(mktemp -d "$DOWNLOAD_DIR/unpack_${BASENAME}_XXXX")

echo "[INFO] Processing $ZIPFILE"
unzip -q "$ZIPFILE" -d "$WORK"

# Process logs → JSON
LOG_JSON="$WORK/logs.json"
: > "$LOG_JSON"
for logfile in "$WORK"/*.log; do
    [ -e "$logfile" ] || continue
    python3 "$(dirname "$0")/logs_to_json.py" "$logfile" >> "$LOG_JSON" || echo "[WARN] Failed $logfile"
done

# Process core dumps → JSON
CORE_JSON="$WORK/cores.json"
: > "$CORE_JSON"
for core in "$WORK"/core*; do
    [ -e "$core" ] || continue
    binary="$WORK/bin/nordbo"  # juster stien til din bin, hvis nødvendig
    timestamp=$(date -Iseconds) # fallback timestamp
    bash "$(dirname "$0")/parse_core.sh" "$core" "$timestamp" "$binary" >> "$CORE_JSON" || echo "[WARN] Failed $core"
done

# Merge logs + cores → NDJSON i kronologisk rækkefølge
NDJSON_FILE="$WORK/out.ndjson"
jq -c -s 'sort_by(.timestamp)[]' "$LOG_JSON" "$CORE_JSON" > "$NDJSON_FILE"

# Send til Elasticsearch
python3 "$(dirname "$0")/indexer.py" "$NDJSON_FILE" || echo "[WARN] Failed indexing $ZIPFILE"

# Flyt ZIP til processed
mv "$ZIPFILE" "$PROCESSED_DIR/"
rm -rf "$WORK"

echo "[INFO] Finished processing $ZIPFILE"
