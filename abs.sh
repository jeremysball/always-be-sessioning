#!/bin/sh
: "${ABS_INTERVAL:=5h}"

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/abs"
LOG_FILE="$LOG_DIR/abs.log"

usage() {
    echo "Usage: abs.sh {run|logs}" >&2
}

cmd_run() {
    mkdir -p "$LOG_DIR" || { echo "abs.sh: failed to create $LOG_DIR" >&2; exit 1; }

    trap 'kill "$sleep_pid" 2>/dev/null; exit 0' TERM INT

    while true; do
        claude --print "." >/dev/null 2>&1
        status=$?
        ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        if [ "$status" -eq 0 ]; then
            echo "$ts ok" >> "$LOG_FILE"
        else
            echo "$ts fail (exit $status)" >> "$LOG_FILE"
        fi
        sleep "$ABS_INTERVAL" &
        sleep_pid=$!
        wait "$sleep_pid"
    done
}

cmd_logs() {
    mkdir -p "$LOG_DIR" || { echo "abs.sh: failed to create $LOG_DIR" >&2; exit 1; }
    touch "$LOG_FILE"
    exec tail -f "$LOG_FILE"
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
