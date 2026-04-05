#!/bin/bash
# ~/.config/hypr/scripts/master-roll.sh
# Wraps rollnext/rollprev to fix a Hyprland quirk: when a window becomes
# the new master via roll, it brings its own stored mfact (typically 0.5
# from left/right orientation), causing it to expand wider than the slaves.
# Works with both regular and special workspaces.
#
# Usage:
#   master-roll.sh next
#   master-roll.sh prev

MFACT=0.34
DIRECTION="${1:-next}"

# Use activewindow to get workspace ID — this correctly returns
# special workspace IDs (negative) unlike activeworkspace
WORKSPACE_ID=$(hyprctl activewindow -j | jq -r '.workspace.id')
if [ -z "$WORKSPACE_ID" ] || [ "$WORKSPACE_ID" = "null" ]; then
    WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r '.id')
fi

STATE_FILE="/tmp/hypr_orientation_state_ws-${WORKSPACE_ID}"
CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "left")

if [ "$CURRENT_STATE" = "center" ]; then
    hyprctl --batch "dispatch layoutmsg roll${DIRECTION} ; dispatch layoutmsg mfact exact ${MFACT}"
else
    hyprctl dispatch layoutmsg "roll${DIRECTION}"
fi
