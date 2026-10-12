#!/bin/bash
set -euo pipefail

# Функция для логирования
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Функция для ошибок
error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
    exit 1
}

# Проверка аргументов
[[ $# -ne 1 ]] && error "Usage: $0 <service>"

SERVICE="$1"

log "Checking $SERVICE status"

if systemctl is-active --quiet "$SERVICE"; then
    log "$SERVICE is up and running!"
else
    log "$SERVICE is not running. Last 10 log lines:"
    journalctl -u "$SERVICE" -n 10
    ERROR_COUNT=$(
        { grep -i "error" /var/log/syslog || true; } |
        awk -v cutoff="$(date -d '1 hour ago' +%s)" '
        {
            cmd = "date -d \"" $1 "\" +%s"
            cmd | getline ts
            close(cmd)

            if (ts >= cutoff)
                count++
        }
        END {
            print count + 0
        }'
    )
    log "Number of errors in /var/log/syslog for the last hour: $ERROR_COUNT"
fi
