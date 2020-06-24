#!/usr/bin/env bash

selection=$(echo -e '󰍁 lock\n󰍃 log off\n󰜉 restart\n󰐥 shutdown' | rofi -dmenu -theme config-power -p "")

case "${selection}" in
  "󰍁 lock")
    i3lock -i /tmp/lock.png -ubte;;
  "󰍃 log off")
    i3-msg exit;;
  "󰜉 restart")
    systemctl reboot;;
  "󰐥 shutdown")
    systemctl poweroff -i;;
esac