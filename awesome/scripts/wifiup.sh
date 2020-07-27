#! /usr/bin/env bash
ip link show | grep ': wl' | awk '{print $9}' | diff <(echo "UP") -