#!/bin/bash
# Import all configs

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
cd ..

########################
####### Hyprland #######
###                  ###

# Dotfiles
DOTS="$USER_HOME/.local/share/omarchy-overrides"
HYPR_DOTS="$DOTS/hypr"

# Local
HYPR_CFG="$USER_HOME/.config/hypr"
HYPR_SCRIPTS="$HYPR_CFG/scripts"

cp -f $HYPR_DOTS/input.conf $HYPR_CFG/input.conf
cp -f $HYPR_DOTS/bindings.conf $HYPR_CFG/bindings.conf
cp -f $HYPR_DOTS/bindings-submap-vm-passthru.conf $HYPR_CFG/bindings-submap-vm-passthru.conf

### Deprecated
# cp -f bindings-overrides.conf $HYPR_CFG/bindings-overrides.conf
# cp -f bindings-speechnote.conf $HYPR_CFG/bindings-speechnote.conf

cp -f $HYPR_DOTS/layout-master.conf $HYPR_CFG/layout-master.conf
cp -f $HYPR_DOTS/layout-dwindle.conf $HYPR_CFG/layout-dwindle.conf

cp -f $HYPR_DOTS/monitors.conf $HYPR_CFG/monitors.conf

cp -f $HYPR_DOTS/windows.conf $HYPR_CFG/windows.conf
cp -f $HYPR_DOTS/autostart.conf $HYPR_CFG/autostart.conf
cp -f $HYPR_DOTS/envs.conf $HYPR_CFG/envs.conf
cp -f $HYPR_DOTS/looknfeel.conf $HYPR_CFG/looknfeel.conf

# scripts
mkdir -p $HYPR_SCRIPTS
cp -f $DOTS/hypr/scripts/hyprgamemode.sh $HYPR_SCRIPTS/hyprgamemode.sh
cp -f $DOTS/hypr/scripts/delta-resize.sh $HYPR_SCRIPTS/delta-resize.sh
cp -f $DOTS/hypr/scripts/orientation-cycle.sh $HYPR_SCRIPTS/orientation-cycle.sh
cp -f $DOTS/hypr/scripts/master-roll.sh $HYPR_SCRIPTS/master-roll.sh
cp -f $DOTS/hypr/scripts/center-mfact-daemon.sh $HYPR_SCRIPTS/center-mfact-daemon.sh
chmod 755 $HYPR_SCRIPTS/*.sh

###                  ###
####### Hyprland #######
########################

########################
######## Other #########
###                  ###

# tmux
TMUX_CFG="$USER_HOME/.config/tmux"
mkdir -p $TMUX_CFG
cp -f $DOTS/tmux/tmux.conf $TMUX_CFG/tmux.conf

# fcitx5
FCITX5_CFG="$USER_HOME/.config/fcitx5/conf"
mkdir -p $FCITX5_CFG
cp -f $DOTS/fcitx5/spell.conf $FCITX5_CFG/spell.conf

# Waybar
cp -f $DOTS/waybar/config.jsonc $USER_HOME/.config/waybar/config.jsonc

###                  ###
######## Other #########
########################


# wait a couple seconds, reloading hyprland + waybar
sleep 1
hyprctl reload
sleep 1
killall waybar
waybar > /dev/null 2>&1 &

echo "Environment reloaded."
echo -e "END: import-configs.sh"
