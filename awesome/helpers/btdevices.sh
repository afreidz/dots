#! /usr/bin/env bash
bt-device -l | grep -v 'Added devices' | awk '{$NF=""; print $0}' | grep -v 'No devices'