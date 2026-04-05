#!/bin/bash
# ~/.config/hypr/scripts/center-mfact-daemon.sh
# Listens for openwindow events via Hyprland's socket2.
# When a window opens and it's the only tiled window on a workspace
# in center orientation, re-applies mfact 0.34 to override the default.
#
# Start with:  exec-once = ~/.config/hypr/scripts/center-mfact-daemon.sh

MFACT=0.34
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

handle() {
    case $1 in
        openwindow*)
            sleep 0.05

            # Get workspace from the active window — this correctly returns
            # special workspace IDs (negative) unlike activeworkspace
            WORKSPACE_ID=$(hyprctl activewindow -j | jq -r '.workspace.id')
            [ -z "$WORKSPACE_ID" ] || [ "$WORKSPACE_ID" = "null" ] && return

            STATE_FILE="/tmp/hypr_orientation_state_ws-${WORKSPACE_ID}"
            CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "left")

            [ "$CURRENT_STATE" != "center" ] && return

            WIN_COUNT=$(hyprctl clients -j | jq --argjson ws "$WORKSPACE_ID" \
                '[.[] | select(.workspace.id == $ws and .floating == false)] | length')

            [ "$WIN_COUNT" -eq 1 ] && hyprctl dispatch layoutmsg "mfact exact ${MFACT}"
            ;;
    esac
}

nc -U "$SOCKET" | while read -r line; do
    handle "$line"
done
