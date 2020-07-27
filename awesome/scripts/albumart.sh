#! /usr/bin/env bash
ART_TMP_DIR=$HOME/.config/awesome/tmp/media
mkdir -p $ART_TMP_DIR
rm -f $ART_TMP_DIR/*.jpg

ART_URL=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 1 "artUrl"| egrep -v "artUrl" | awk -F '"' '{print $2}' | sed -e 's/open.spotify.com/i.scdn.co/g');
DEST_PATH=$ART_TMP_DIR
DEST_FILENAME=$(( $(date '+%s%N') / 1000000)).jpg
curl -so $DEST_PATH/$DEST_FILENAME $ART_URL
echo $DEST_PATH/$DEST_FILENAME