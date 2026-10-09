#!/bin/bash

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/diagnostic.log"

mkdir -p "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

host="$1"
port="$2"

log_message "Network check started for host='$host' port='$port'"

if [[ -z "$host" ]]; then
    echo "Usage: $0 <hostname-or-ip> [port]"
    log_message "Network check failed: missing host"
    exit 2
fi

if [[ -n "$port" ]]; then
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: port must be numeric."
        log_message "Network check failed: non-numeric port"
        exit 2
    fi

    if (( port < 1 || port > 65535 )); then
        echo "Error: port must be between 1 and 65535."
        log_message "Network check failed: port outside valid range"
        exit 2
    fi
fi

echo "===== NETWORK CHECK ====="
echo "Host: $host"

resolved_address=$(getent ahosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')

if [[ -z "$resolved_address" ]]; then
    echo "Error: unable to resolve host: $host"
    log_message "Network check failed: unable to resolve host"
    exit 1
fi

echo "Resolved Address: $resolved_address"

if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
    echo "Connectivity: reachable"
    log_message "Ping connectivity successful for $host"
else
    echo "Connectivity: ping failed or blocked"
    log_message "Ping failed or blocked for $host"
fi

echo
echo "===== NETWORK INTERFACES ====="
ip -brief address

if [[ -n "$port" ]]; then
    echo
    echo "===== TCP CONNECTIVITY ====="
    echo "Checking $host:$port"

    if timeout 5 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        echo "TCP connectivity: successful"
        log_message "TCP connectivity successful for $host:$port"
        exit 0
    else
        echo "TCP connectivity: failed"
        log_message "TCP connectivity failed for $host:$port"
        exit 1
    fi
fi

log_message "Network check completed successfully for $host"
exit 0
