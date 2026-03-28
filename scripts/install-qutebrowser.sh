#!/bin/bash
USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")

yay -Syy
yay -S qutebrowser python-adblock --needed

ln -sv $USER_HOME/.local/share/omarchy-overrides/qutebrowser/config.py $USER_HOME/.config/qutebrowser/config.py
