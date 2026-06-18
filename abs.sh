#!/bin/sh
: "${ABS_INTERVAL:=5h}"

trap 'kill "$sleep_pid" 2>/dev/null; exit 0' TERM INT

while true; do
    claude --print "." >/dev/null 2>&1
    sleep "$ABS_INTERVAL" &
    sleep_pid=$!
    wait "$sleep_pid"
done
