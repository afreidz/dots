#! /usr/bin/env bash
PLAYING="spotifycli --playbackstatus"
ARTIST="spotifycli --artist"
SONG="spotifycli --song"

if [[ $($PLAYING 2>&1) == "▶" ]]; then
  echo 'playing'
  echo $($SONG)
  echo $($ARTIST)
elif [[ $($PLAYING 2>&1) == "Spotify is off" ]]; then
  echo 'not playing'
  echo 'Nothing Playing'
  echo ''
else
  echo 'not playing'
  echo $($SONG)
  echo $($ARTIST)
fi

