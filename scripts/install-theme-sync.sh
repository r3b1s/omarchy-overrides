#!/bin/bash
USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
DOTS=$USER_HOME/.local/share/omarchy-overrides
OMARCHY_BIN=$USER_HOME/.local/share/omarchy/bin

cd /tmp

sleep 3

# Clone via https as a fallback
if [[ ! -d "/tmp/omarchy-theme-sync" ]]; then
  echo -e "\nCloning omarchy-theme-sync using https..."
  git clone https://github.com/reg1z/omarchy-theme-sync
fi

cd omarchy-theme-sync

chmod 755 install.sh
chmod 755 omarchy-theme-sync

./install.sh
sleep 1

rm -rf /tmp/omarchy-theme-sync

echo -e "END: install-theme-sync.sh"
