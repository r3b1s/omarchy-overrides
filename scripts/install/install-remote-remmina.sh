#!/bin/bash
# Install remmina remote desktop client

# Update repos
yay -Syy

# Support packages
# - VNC: libvncserver
# - SPICE: spice-gtk
# - RDP: freerdp
yay -S --needed --noconfirm \
  remmina \
  libvncserver \
  spice-gtk \
  freerdp


