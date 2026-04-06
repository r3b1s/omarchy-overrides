#!/usr/bin/env bash
# Installs my kanata keyboard layout.
# Clones into tmp and then cleans up files.
exit 0

cd /tmp
yay -S --needed --noconfirm rust 
echo -e "\nCloning keyboard layout repo."
git clone https://github.com/reg1z/kanata-enthium.git
sleep 5
cd kanata-enthium
sudo chmod +x install-kanata.sh
sudo ./install-kanata.sh
echo -e "\nInstallation complete. Removing keyboard repo."
rm -rf kanata-enthium

echo -e "END: install_kanata_enthium.sh"
