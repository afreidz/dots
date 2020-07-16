#! /user/env bash
ip link show | grep ': en' | awk '{print $9}' | diff <(echo "UP") -