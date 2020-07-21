#! /usr/bin/env bash
free | grep Mem | awk '{print $3/$2 * 100.0}'