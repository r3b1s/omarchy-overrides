#!/bin/bash
# Reestablishes symbolic links &
# reimports files.
#
# Intended to be used after unlinking
# & updating omarchy.

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
DOTS="$USER_HOME/.local/share/omarchy-overrides"
OMARCHY_BIN="$USER_HOME/.local/share/omarchy/bin"

# Reimport Real Files
$DOTS/scripts/import-backgrounds.sh
mv -v /tmp/omarchy-theme-sync $OMARCHY_BIN/omarchy-theme-sync

# Reestablish Symbolic Links
$DOTS/scripts/link-webapp-firefox.sh
$DOTS/scripts/link-configs.sh link

echo -e "Finished. Waiting a moment to let system settle..."
sleep 3
echo -e "END: omarchy-relink.sh"
