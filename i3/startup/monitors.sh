#!/usr/bin/env bash
xrandr --auto
TOTALMONS=$(eval "xrandr -q | grep ' connected' | cut -d ' ' -f1 | wc -l")
CMD=$(eval "xrandr -q | grep ' connected' | cut -d ' ' -f1")
MONS=($CMD)

export MONITORS=${TOTALMONS}
export MONITOR_PRIMARY=${MONS[0]}
export MONITOR_SECONDARY=${MONS[-1]}