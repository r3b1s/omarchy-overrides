#!/bin/bash

SPINNER="pulse"

# Install zellij
echo "Installing zellij..."
gum spin --spinner "$SPINNER" --title "Installing zellij..." -- \
  yay -S --needed --noconfirm zellij

echo "Zellij installed."

# Offer theme syncing
if gum confirm "Would you like to install omarchy-zellij-theme (syncs Zellij colors with omarchy themes)?"; then
  echo "Installing omarchy-zellij-theme..."
  gum spin --spinner "$SPINNER" --title "Cloning omarchy-zellij-theme..." -- bash -c "
    rm -rf /tmp/omarchy-zellij-theme
    git clone https://github.com/skvggor/omarchy-zellij-theme /tmp/omarchy-zellij-theme
  "
  /tmp/omarchy-zellij-theme/install.sh
  rm -rf /tmp/omarchy-zellij-theme
  echo "omarchy-zellij-theme installed."
else
  echo "Skipping theme sync."
fi
