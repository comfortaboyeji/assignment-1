#!/bin/bash

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/diagnostic.log"

mkdir -p "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "System information check started"

echo "===== SYSTEM INFORMATION ====="

echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Date/Time: $(date)"
echo "Operating System: $(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p)"

echo "CPU Information:"
lscpu | grep -E 'Model name|CPU\(s\)' | head -n 2

echo "Memory Information:"
free -h

echo "Current Working Directory: $(pwd)"

log_message "System information check completed successfully"
