#!/bin/sh
# Import custom backgrounds into
# omarchy's default themes.

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
DOTS=$USER_HOME/.local/share/omarchy-overrides

themes=(
  "catppuccin"
  "catppuccin-latte"
  "ethereal"
  "everforest"
  "flexoki-light"
  "gruvbox"
  "hackerman"
  "kanagawa"
  "matte-black"
  "nord"
  "osaka-jade"
  "ristretto"
  "rose-pine"
  "tokyo-night"
  "vantablack"
  "white"
  "miasma"
)

BACKGROUNDS=$DOTS/backgrounds

# If adding "sever" as the first argument,
# unlink backgrounds.
if [[ "$1" == "remove"  ]]; then

  for theme in "${themes[@]}"; do
    for i in 00 01 02 03 04 05 06 07 08 09; do
      if [[ -f $BACKGROUNDS/$i-$theme.png ]]; then
        rm -v "$HOME/.config/omarchy/backgrounds/$theme/$i-$theme.png"
      fi
    done
  done

# Else, link them.
else

  for theme in "${themes[@]}"; do
    mkdir -p "$HOME/.config/omarchy/backgrounds/$theme"
    for i in 00 01 02 03 04 05 06 07 08 09; do
      if [[ -f $BACKGROUNDS/$i-$theme.png ]]; then
        cp -v "$DOTS/backgrounds/$i-$theme.png" "$HOME/.config/omarchy/backgrounds/$theme/$i-$theme.png"
      fi
    done
  done

fi

echo -e "END: import-backgrounds.sh $1"
