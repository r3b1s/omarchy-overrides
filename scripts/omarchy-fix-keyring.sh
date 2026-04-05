#!/bin/bash
# temp fix from ihazucha: https://github.com/basecamp/omarchy/discussions/3331#discussioncomment-15147786

echo "Wiping keyring..."
rm $HOME/.local/share/keyrings/*

echo "Running default-keyring.sh and sddm.sh..."
bash $HOME/.local/share/omarchy/install/login/default-keyring.sh
bash $HOME/.local/share/omarchy/install/login/sddm.sh

echo "You can safely restart your system."
