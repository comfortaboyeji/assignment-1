#!/bin/bash

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/diagnostic.log"

mkdir -p "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

threshold="$1"
path="${2:-/}"

log_message "Disk check started with threshold='$threshold' path='$path'"

if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
    echo "Error: threshold must be an integer from 1 to 100."
    log_message "Disk check failed: invalid threshold"
    exit 2
fi

if (( threshold < 1 || threshold > 100 )); then
    echo "Error: threshold must be between 1 and 100."
    log_message "Disk check failed: threshold outside valid range"
    exit 2
fi

if [[ ! -e "$path" ]]; then
    echo "Error: path does not exist: $path"
    log_message "Disk check failed: path does not exist"
    exit 2
fi

usage=$(df -P "$path" | awk 'NR==2 {gsub("%","",$5); print $5}')

echo "Path: $path"
echo "Disk usage: ${usage}%"
echo "Threshold: ${threshold}%"

if (( usage >= threshold )); then
    echo "WARNING: Disk usage has reached or exceeded the threshold."
    log_message "Disk check warning: usage=${usage}% threshold=${threshold}%"
    exit 1
else
    echo "OK: Disk usage is below the threshold."
    log_message "Disk check successful: usage=${usage}% threshold=${threshold}%"
    exit 0
fi
