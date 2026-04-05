#!/bin/bash
MONITOR=$(hyprctl monitors -j | jq '.[] | select(.focused)')
MONITOR_W=$(echo "$MONITOR" | jq '.width')
MONITOR_H=$(echo "$MONITOR" | jq '.height')

FACTOR=0.055 # Percentage factor to use for calculating the delta

DELTA_X=$(echo "$MONITOR_W * $FACTOR / 1" | bc)
DELTA_Y=$(echo "$MONITOR_H * $FACTOR / 1" | bc)

case "$1" in
    x) hyprctl dispatch resizeactive "$DELTA_X 0" ;;
    -x) hyprctl dispatch resizeactive -- "-$DELTA_X 0" ;;
    y) hyprctl dispatch resizeactive "0 $DELTA_Y" ;;
    -y) hyprctl dispatch resizeactive -- "0 -$DELTA_Y" ;;
esac
