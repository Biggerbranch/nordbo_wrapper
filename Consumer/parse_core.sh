#!/bin/bash
set -euo pipefail

CORE_FILE="$1"
TIMESTAMP="$2"
BINARY="$3"

SCRIPT_DIR="$(dirname "$0")"
LOGDIR="$SCRIPT_DIR/logs"
mkdir -p "$LOGDIR"

GDB_LOG="$LOGDIR/gdb_$(basename "$CORE_FILE").log"

# Run GDB batch to get full backtrace
if ! gdb --batch --quiet -ex "thread apply all bt full" "$BINARY" "$CORE_FILE" > "$GDB_LOG" 2>&1; then
    # If GDB fails, emit a single JSON object with the error
    echo "{\"error\": \"GDB failed\", \"core_file\": \"${CORE_FILE}\", \"timestamp\": \"${TIMESTAMP}\"}"
    exit 1
fi

# Call Python parser to generate NDJSON for this core
python3 "$SCRIPT_DIR/parse_core.py" "$CORE_FILE" "$TIMESTAMP" "$BINARY" "$GDB_LOG"
