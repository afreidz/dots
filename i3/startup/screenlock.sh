#!/usr/bin/env bash
killall -q xidlehook

# Wait until the processes have been shut down
while pgrep -u $UID -x xidlehook >/dev/null; do sleep 1; done

export WALLPAPER=$(awk 'BEGIN { FS = "file=" } ; { print $2 }' $HOME/.config/nitrogen/bg-saved.cfg)
export USERIMG="${HOME}/Pictures/andy-emoji-linicorn.png"
USER=$(whoami)

convert "${WALLPAPER//[$'\t\r\n']}" -resize 1920x1080 -filter Gaussian -blur 0x8 /tmp/wall.png
convert $USERIMG \( +clone -threshold -1 -negate -fill white -draw "circle 400,400,400,0" \) -alpha off -compose copy_opacity -composite /tmp/user.png
convert /tmp/user.png -background transparent -fill white -font Poppins-SemiBold -pointsize 100 label:"Locked by $(echo $USER)" -gravity Center -append /tmp/user.png
composite -gravity center -geometry 200x200+0+0 /tmp/user.png /tmp/wall.png /tmp/lock.png

xidlehook \
  --not-when-audio \
  --timer 120 \
  'i3lock -i /tmp/lock.png -ubte' \
  '' \
  --timer 60 \
  'systemctl suspend' \
  ''