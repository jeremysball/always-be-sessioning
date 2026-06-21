#!/bin/sh
: "${ABS_INTERVAL:=5h}"

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/abs"
LOG_FILE="$LOG_DIR/abs.log"

BACKOFF_BASE=10
BACKOFF_MAX=3600

usage() {
    echo "Usage: abs.sh {run|logs}" >&2
}

cmd_run() {
    mkdir -p "$LOG_DIR" || { echo "abs.sh: failed to create $LOG_DIR" >&2; exit 1; }

    account=$(claude auth status 2>/dev/null | grep '"email"' | sed 's/.*"email": *"\([^"]*\)".*/\1/')
    ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    if [ -n "$account" ]; then
        echo "$ts start account=$account" >> "$LOG_FILE"
    else
        echo "$ts start (account unknown)" >> "$LOG_FILE"
    fi

    trap 'kill "$sleep_pid" 2>/dev/null; exit 0' TERM INT

    backoff="$BACKOFF_BASE"

    while true; do
        claude --print "." >/dev/null 2>&1
        status=$?
        ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        if [ "$status" -eq 0 ]; then
            echo "$ts ok" >> "$LOG_FILE"
            backoff="$BACKOFF_BASE"
            next_sleep="$ABS_INTERVAL"
        else
            echo "$ts fail (exit $status), retrying in ${backoff}s" >> "$LOG_FILE"
            next_sleep="$backoff"
            backoff=$((backoff * 2))
            if [ "$backoff" -gt "$BACKOFF_MAX" ]; then
                backoff="$BACKOFF_MAX"
            fi
        fi
        sleep "$next_sleep" &
        sleep_pid=$!
        wait "$sleep_pid"
    done
}

cmd_logs() {
    mkdir -p "$LOG_DIR" || { echo "abs.sh: failed to create $LOG_DIR" >&2; exit 1; }
    touch "$LOG_FILE"
    if [ ! -s "$LOG_FILE" ]; then
        echo "No log entries yet."
        return
    fi
    exec "${PAGER:-less}" "$LOG_FILE"
}

case "$1" in
    run)
        cmd_run
        ;;
    logs)
        cmd_logs
        ;;
    *)
        usage
        exit 1
        ;;
esac
