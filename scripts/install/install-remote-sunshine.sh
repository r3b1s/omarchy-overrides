#!/bin/bash
# Install sunshine remote desktop server
# - Must be ran as sudo
#
# Adds sunshine official repo to pacman.conf if not present.
# - Repository: https://github.com/LizardByte/pacman-repo

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

if [[ "$1" == "uninstall" ]]; then
  pacman -Rns sunshine
  echo "Sunshine uninstalled"
  echo 
  sed -i '/# SUNSHINE OFFICIAL REPO ---/,/# SUNSHINE OFFICIAL REPO ---/d' /etc/pacman.conf
  echo -e "\nSunshine official repo removed from /etc/pacman.conf"
  pacman -Syy
  exit 0
fi

if ! grep -F '# SUNSHINE OFFICIAL REPO ---' /etc/pacman.conf || ! grep -F '[lizardbyte]' /etc/pacman.conf ]; then
  echo -e "\nAdding sunshine official repo (lizardbyte) to /etc/pacman.conf\n"

sudo cat >> /etc/pacman.conf << 'EOF'

# SUNSHINE OFFICIAL REPO ---
[lizardbyte]
SigLevel = Optional
Server = https://github.com/LizardByte/pacman-repo/releases/latest/download
# SUNSHINE OFFICIAL REPO ---
EOF
fi

pacman -Syy
pacman -S lizardbyte/sunshine

exit 0
