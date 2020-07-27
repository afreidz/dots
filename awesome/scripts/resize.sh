#! /usr/bin/env bash
TMP=$HOME/.config/awesome/tmp/display
mkdir -p $TMP
rm $TMP/*.jpg
convert $1 -scale $2x$3! -gravity center $TMP/wall_$4.jpg