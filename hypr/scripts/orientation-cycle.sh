#!/bin/bash
# ~/.config/hypr/scripts/orientation-cycle.sh
# Cycles through master layout orientations: left -> center -> right
# and adjusts mfact accordingly (0.5 for left/right, 0.33 for center).
# Works with both regular and special workspaces.

# Use activewindow to get workspace ID — this correctly returns
# special workspace IDs (negative) unlike activeworkspace

MFACT=0.34
WORKSPACE_ID=$(hyprctl activewindow -j | jq -r '.workspace.id')

# Fallback to activeworkspace if no window is focused (empty workspace)
if [ -z "$WORKSPACE_ID" ] || [ "$WORKSPACE_ID" = "null" ]; then
    WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r '.id')
fi

STATE_FILE="/tmp/hypr_orientation_state_ws-${WORKSPACE_ID}"
CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "left")

case "$CURRENT_STATE" in
    left)
        hyprctl --batch "dispatch layoutmsg orientationcenter ; dispatch layoutmsg mfact exact ${MFACT}"
        echo "center" > "$STATE_FILE"
        ;;
    center)
        hyprctl --batch "dispatch layoutmsg orientationright ; dispatch layoutmsg mfact exact 0.5"
        echo "right" > "$STATE_FILE"
        ;;
    right)
        hyprctl --batch "dispatch layoutmsg orientationleft ; dispatch layoutmsg mfact exact 0.5"
        echo "left" > "$STATE_FILE"
        ;;
esac
