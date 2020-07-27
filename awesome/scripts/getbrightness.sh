#! /usr/bin/env bash
MONITOR_NAMES=($(xrandr --listmonitors | grep '^\s' | awk '{print $4}'))
MONITOR_BRIGHTNESSES=($(xrandr --verbose | grep Brightness | grep -o '[0-9].*'))

for i in "${!MONITOR_NAMES[@]}"; do
  if [ "$1" == "${MONITOR_NAMES[i]}" ]; then
    echo "${MONITOR_BRIGHTNESSES[i]}"
  fi
done

#xrandr --output $1 --brightness $2