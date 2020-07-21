#! /usr/bin/env bash
echo $(awk 'BEGIN { FS = "file=" } ; { print $2 }' $HOME/.config/nitrogen/bg-saved.cfg | sed -n '/./{p;q;}')