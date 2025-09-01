#!/bin/bash
# config.sh

# Elasticsearch
export ES_HOST="https://localhost:9200"
export ES_USER="elastic"
export ES_PASS="B0r_7ARJkK9-jhXZZ4nG"   # <- i praksis hentes fra secret manager/env var
export ES_INDEX="crash_logs"

# Cloud (Google Drive, S3, etc.)
# Hvis Google Drive bruges → rclone anbefales
export CLOUD_REMOTE="gdrive:1Y6euOzGfxi5FOqbKYvgdoUXTGies_Ofn"
export DOWNLOAD_DIR="$HOME/consumer/workdir"
export PROCESSED_DIR="$HOME/consumer/processed"
export LOGDIR="$HOME/consumer/logs"

mkdir -p "$DOWNLOAD_DIR" "$PROCESSED_DIR" "$LOGDIR"