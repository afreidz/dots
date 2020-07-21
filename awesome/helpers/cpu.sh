#! /usr/bin/env bash
top -n 1 -b | grep Cpu | awk '{usage=100-$8} END {print usage}'