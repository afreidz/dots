#! /usr/bin/env bash
ART_TMP_DIR=$HOME/.config/awesome/tmp/media
ART_PATH=$ART_TMP_DIR/cover.jpg
mkdir -p $ART_TMP_DIR

ART_URL=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 1 "artUrl"| egrep -v "artUrl" | awk -F '"' '{print $2}' | sed -e 's/open.spotify.com/i.scdn.co/g');

curl -o $ART_PATH $ART_URL