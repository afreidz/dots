#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if [ $MONITORS -eq 2 ]; then
  polybar launch &\
  polybar power &\
  polybar workspaces1 &\
  polybar workspaces2 &\
  polybar utilities &\
  polybar datetime1 &\
  polybar datetime2 &\
  polybar system1 &\
  polybar system2 &\
  polybar spacer1 &\
  polybar spacer2 &
else
  polybar launch &\
  polybar power &\
  polybar workspaces1 &\
  polybar utilities &\
  polybar datetime1 &\
  polybar system2 &\
  polybar spacer1 &\
fi