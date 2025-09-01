#!/bin/bash
set -uo pipefail
ulimit -c unlimited  # Tillad ubegrænsede core dumps

# ================== KONFIG ==================
COREDIR="$HOME/nordbo_wrapper/core"
LOGDIR="$HOME/nordbo_wrapper/logs"
PENDINGDIR="$HOME/nordbo_wrapper/pending"
BINARY="$HOME/Downloads/nordbo_isav/build/nordbo_isav"

mkdir -p "$COREDIR" "$LOGDIR" "$PENDINGDIR"

# Midlertidigt sætte core dump navn (unik per kørsel)
sudo sysctl -w kernel.core_pattern="$COREDIR/core.%e.%p.%t" >/dev/null 2>&1 || true

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOGFILE="$LOGDIR/nordbo_isav_$TIMESTAMP.log"
ZIP_FILE="$PENDINGDIR/nordbo_isav_$TIMESTAMP.zip"

log_message() {
    echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $1" | tee -a "$LOGFILE"
}

request_consent() {
    if command -v zenity >/dev/null 2>&1; then
        timeout 30 zenity --question --text="Send crash log to Nordbo for analysis?" --title="Crash Report"
        return $?
    else
        read -p "Send crash log to Nordbo for analysis? (y/n): " answer
        [[ "$answer" =~ ^[Yy]$ ]]
        return $?
    fi
}

# ================== KØR PROGRAM ==================
log_message "Running program with args: $@"
"$BINARY" "$@" >> "$LOGFILE" 2>&1
EXIT_CODE=$?
log_message "Program exited with code $EXIT_CODE"

# ================== HÅNDTER CRASH ==================
if [ $EXIT_CODE -ne 0 ]; then
    log_message "Program crashed with exit code $EXIT_CODE"

    if request_consent; then
        # Find core dump i COREDIR eller PWD
        CORE_FILE=$(find "$COREDIR" "$PWD" -maxdepth 1 -name 'core*' -type f -mmin -5 | sort -r | head -n1)

        if [ -n "$CORE_FILE" ]; then
            zip -j "$ZIP_FILE" "$LOGFILE" "$CORE_FILE" >/dev/null 2>&1 && \
            log_message "Created pending zip: $ZIP_FILE (with core)"
        else
            zip -j "$ZIP_FILE" "$LOGFILE" >/dev/null 2>&1 && \
            log_message "Created pending zip: $ZIP_FILE (no core found)"
        fi
    else
        log_message "User declined to send crash log"
    fi
else
    log_message "Program closed normally"
fi

exit $EXIT_CODE
