#!/bin/bash
# Sets up firefox as the default browser.
# Firefox will be used PWAs in place of chromium.
# System-wide policy will automatically install
# ublock-origin and disable telemetry across all
# profiles.

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
DOTS=$USER_HOME/.local/share/omarchy-overrides
FFOX_DOTS="$DOTS/firefox"
FFOX_CFG="$USER_HOME/.mozilla/firefox"
OMARCHY_BIN=$USER_HOME/.local/share/omarchy/bin

# Import policies .json (enforces ublock origin, disabled telemetry, etc. system-wide)
sudo mkdir -p /etc/firefox/policies
sudo cp -f $FFOX_DOTS/policies.json /etc/firefox/policies/policies.json
sudo chown root:root /etc/firefox/policies/policies.json
sudo chmod 644 /etc/firefox/policies/policies.json

# Install firefox if not present
yay -Sy --needed firefox

############################
##### Browser Profiles #####
###                      ###
echo -e "Setting up Firefox Browser Profiles"

# Personal
PROFILE="Personal"
if [[ -d $FFOX_CFG/$PROFILE ]]; then
  echo "$PROFILE profile already present! Skipping..."
else
  echo -e "Setting up $PROFILE Profile...\n"
  firefox -no-remote -CreateProfile "$PROFILE $FFOX_CFG/$PROFILE"
  sleep 5
  cp -RTf "$FFOX_DOTS/templates/$PROFILE/" "$FFOX_CFG/$PROFILE/"
  sleep 1
fi

# Work
PROFILE="Work"
if [[ -d $FFOX_CFG/$PROFILE ]]; then
  echo "$PROFILE profile already present! Skipping..."
else
  echo -e "Setting up $PROFILE Profile...\n"
  firefox -no-remote -CreateProfile "$PROFILE $FFOX_CFG/$PROFILE"
  sleep 5
  cp -RTf "$FFOX_DOTS/templates/$PROFILE/" "$FFOX_CFG/$PROFILE/"
  sleep 1
fi

###                      ###
##### Browser Profiles #####
############################

# Set firefox as default browser
xdg-settings set default-web-browser firefox.desktop

echo "END: setup-firefox.sh"
