#!/usr/bin/env bash
# Reverse all Speech Note and ydotool configuration

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
CURRENT_USER=$(whoami)
USER_ID=$(id -u $CURRENT_USER)

echo "=== Speech Note & ydotool Uninstall Script ==="
echo "This will remove all Speech Note and ydotool configuration"
echo "Current user: $CURRENT_USER (ID: $USER_ID)"
echo "User home: $USER_HOME"
echo

# Confirm before proceeding
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Uninstall cancelled."
  exit 0
fi

echo "=== Stopping and disabling systemd services ==="

# Stop running services
systemctl --user stop speechnote.service 2>/dev/null || true
systemctl --user stop ydotool.service 2>/dev/null || true

# Disable services
systemctl --user disable speechnote.service 2>/dev/null || true
systemctl --user disable ydotool.service 2>/dev/null || true

# Remove service files
if [ -f "$USER_HOME/.config/systemd/user/speechnote.service" ]; then
  rm -f "$USER_HOME/.config/systemd/user/speechnote.service"
  echo "Removed speechnote.service"
fi

if [ -f "$USER_HOME/.config/systemd/user/ydotool.service" ]; then
  rm -f "$USER_HOME/.config/systemd/user/ydotool.service"
  echo "Removed ydotool.service"
fi

# Reload systemd to reflect changes
systemctl --user daemon-reload
echo "Reloaded systemd user daemon"

echo
echo "=== Removing Flatpak permissions ==="

# Reset Speech Note Flatpak permissions
flatpak override --user --reset net.mkiol.SpeechNote 2>/dev/null &&
  echo "Reset Speech Note Flatpak permissions" ||
  echo "No Speech Note Flatpak permissions to reset"

echo
echo "=== Cleaning up socket directory ==="

# Remove socket directory
if [ -d "/run/user/$USER_ID/ydotoold" ]; then
  rm -rf "/run/user/$USER_ID/ydotoold"
  echo "Removed socket directory: /run/user/$USER_ID/ydotoold"
fi

echo
echo "=== Removing user from input group ==="

# Check if user is in input group before attempting removal
if groups $CURRENT_USER | grep -q '\binput\b'; then
  # Remove user from input group
  sudo gpasswd -d $CURRENT_USER input
  echo "Removed $CURRENT_USER from input group"
  echo "Note: You may need to log out and back in for group changes to take effect"
else
  echo "User $CURRENT_USER is not in the input group"
fi

echo
echo "=== Package removal options ==="

# Ask about removing ydotool package
read -p "Do you want to remove the ydotool package? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo pacman -Rns ydotool
  echo "Removed ydotool package and dependencies"
else
  echo "Kept ydotool package (it may be used by other applications)"
fi

# Ask about removing Speech Note Flatpak
read -p "Do you want to uninstall Speech Note Flatpak application? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  flatpak uninstall --user net.mkiol.SpeechNote
  echo "Uninstalled Speech Note Flatpak application"
else
  echo "Kept Speech Note Flatpak application"
fi

# Ask about removing Speech Note data
read -p "Do you want to remove Speech Note user data? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ -d "$USER_HOME/.var/app/net.mkiol.SpeechNote" ]; then
    rm -rf "$USER_HOME/.var/app/net.mkiol.SpeechNote"
    echo "Removed Speech Note user data"
  else
    echo "No Speech Note user data found"
  fi

  if [ -d "$USER_HOME/.local/share/net.mkiol/dsnote" ]; then
    rm -rf "$USER_HOME/.local/share/net.mkiol/dsnote"
    echo "Removed Speech Note configuration data"
  else
    echo "No Speech Note configuration data found"
  fi
else
  echo "Kept Speech Note user data and configuration"
fi

echo
echo "=== Cleanup verification ==="

# Verify services are no longer active
if systemctl --user is-active --quiet speechnote.service 2>/dev/null; then
  echo "⚠️  WARNING: speechnote.service is still active"
else
  echo "✓ speechnote.service is not active"
fi

if systemctl --user is-active --quiet ydotool.service 2>/dev/null; then
  echo "⚠️  WARNING: ydotool.service is still active"
else
  echo "✓ ydotool.service is not active"
fi

# Check if socket directory still exists
if [ -d "/run/user/$USER_ID/ydotoold" ]; then
  echo "⚠️  WARNING: Socket directory still exists: /run/user/$USER_ID/ydotoold"
else
  echo "✓ Socket directory cleaned up"
fi

# Check group membership
if groups $CURRENT_USER | grep -q '\binput\b'; then
  echo "⚠️  WARNING: $CURRENT_USER is still in input group (may require logout/login)"
else
  echo "✓ User removed from input group"
fi

echo
echo "Fin."

# echo
# echo "=== Uninstall Summary ==="
# echo "The following changes have been made:"
# echo "• Stopped and disabled Speech Note and ydotool systemd services"
# echo "• Removed systemd service files from ~/.config/systemd/user/"
# echo "• Reset Speech Note Flatpak permissions"
# echo "• Removed ydotool socket directory"
# echo "• Removed user from input group (if it was a member)"
# echo
# echo "Optional actions taken based on your choices:"
# echo "• ydotool package removal"
# echo "• Speech Note Flatpak application removal"
# echo "• Speech Note user data removal"
# echo
# echo "=== Important Notes ==="
# echo "• You may need to log out and back in for group changes to take effect"
# echo "• If you removed ydotool, any other applications using it may be affected"
# echo "• Flatpak permission changes take effect immediately"
# echo "• systemd service changes take effect immediately"
# echo
# echo "Uninstall completed!"
