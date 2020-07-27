#! /usr/bin/env bash
systemctl status bluetooth | grep 'Status' | awk '{print $2}' | diff <(echo "\"Running\"") -