#!/usr/bin/env bash

PID=""
CHECK="spotifycli --playbackstatus"

while sleep 1; do
    if [ $($CHECK | grep "▶") ]; then
        if [[ -z $PID ]]; then
            polybar music & #start music polybar
            PID=$!
        fi
    else
        if [[ -n $PID ]]; then
            kill -9 $PID #kill music polybar
            PID=""
        fi
    fi
done