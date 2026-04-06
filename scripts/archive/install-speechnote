#!/usr/bin/env bash

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
CURRENT_USER=$(whoami)
USER_ID=$(id -u $CURRENT_USER)

# Confirm before proceeding
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "SpeechNote configuration cancelled."
  exit 0
fi

# flatpak is preferred for secure installation of SpeechNote
# ydotool is required for global keyboard shortcuts with Wayland
sudo pacman -S --needed flatpak ydotool

# Ensure flathub is available for user-level installations
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install SpeechNote and its Nvidia Addon
flatpak install --user -y net.mkiol.SpeechNote net.mkiol.SpeechNote.Addon.nvidia
#flatpak install --user -y net.mkiol.SpeechNote.Addon.nvidia

# Add user to necessary group (input)
sudo usermod -aG input $CURRENT_USER

# Ensure user has their own systemd config folder
mkdir -p $USER_HOME/.config/systemd/user

# Create new socket directory for more precise flatpak permissioning
mkdir -p /run/user/$USER_ID/ydotoold
chown $CURRENT_USER:$CURRENT_USER /run/user/$USER_ID/ydotoold
chmod 755 /run/user/$USER_ID/ydotoold

# Import updated ydotoold.service systemd unit into systemd
sed "s/USER_ID_PLACEHOLDER/$USER_ID/g" ./ydotool.service >$USER_HOME/.config/systemd/user/ydotool.service

# Import speechnote.service systemd unit into user's systemd config
cp -f ./speechnote.service $USER_HOME/.config/systemd/user/speechnote.service

# Re-execute user-level systemd instance.
# Makes systemd restart its own process (execve again) without shutting down services.
systemctl --user daemon-reexec

# enable imported systemd services
systemctl --user enable ydotool.service
systemctl --user enable speechnote.service

# Grant SpeechNote flatpak permissions to access the ydotoold socket
#flatpak override --user --filesystem=/run/user/$(id -u)/ydotoold/.ydotoold_socket:rw net.mkiol.SpeechNote
flatpak override --user --filesystem=/run/user/$(id -u)/ydotoold net.mkiol.SpeechNote
flatpak override --user --env=YDOTOOL_SOCKET=/run/user/$(id -u)/ydotoold/.ydotoold_socket net.mkiol.SpeechNote

# Start services
systemctl --user start ydotool.service
systemctl --user start speechnote.service
