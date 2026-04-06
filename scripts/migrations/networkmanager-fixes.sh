#!/usr/bin/env bash

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
CURRENT_USER=$(whoami)
USER_ID=$(id -u $CURRENT_USER)

# Backup omarchy-launch-wifi command
cp -f "$(which omarchy-launch-wifi)" "$(which omarchy-launch-wifi).bak"

# Replace instances of Impala/impala with nmtui for omarchy-menu command
sed -i "s/Impala/nmtui/g" "$(which omarchy-launch-wifi)"
sed -i "s/impala/nmtui/g" "$(which omarchy-launch-wifi)"

# Replace instances of Impala/impala with nmtui for waybar configuration
# sed -i "s/Impala/nmtui/g" "$USER_HOME/.config/waybar/config.jsonc"
# sed -i "s/impala/nmtui/g" "$USER_HOME/.config/waybar/config.jsonc"
