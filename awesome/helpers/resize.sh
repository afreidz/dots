#! /usr/bin/env bash
rm $HOME/.config/awesome/tmp/*.jpg
convert $1 -scale $2x$3! -gravity center $HOME/.config/awesome/tmp/wall_$4.jpg