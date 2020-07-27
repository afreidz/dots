#! /usr/bin/env bash
bt-device -i "$1" | grep 'Connected' | awk '{print $2}' | diff <(echo 1) -