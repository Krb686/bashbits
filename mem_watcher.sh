#!/bin/bash
COMMAND="$@"
PID=
I=1
OUTFILE="/tmp/outfile"

function run_command {
    $COMMAND & &>/dev/null
    PID="$!"
}

function mem_watch {
    while true; do
        ps -p "$PID" -o pid,rsz,vsz,time,etimes,command --no-header &>>"$OUTFILE"
        sleep $I
    done
}

echo "$@"
run_command &>/dev/null
mem_watch
