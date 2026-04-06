#!/usr/bin/env bash
# Download latest xonsh AppImage

XONSH="$HOME/.local/bin/xonsh"

if [ -f $XONSH ] && [ "$1" == "uninstall" ]; then
  rm -v $XONSH
elif [[ "$1" == "uninstall" ]]; then
  echo "Nothing to remove -- xonsh not present"
  echo "No file at: $XONSH"
elif [[ -f $XONSH ]]; then
  echo "xonsh already installed at:"
  echo "$XONSH"
else
  echo "Retrieving the latest xonsh AppImage..."
  gum spin --spinner globe --title "Curling..." -- \
    curl \
    -L 'https://github.com/xonsh/xonsh/releases/latest/download/xonsh-x86_64.AppImage' \
    -o $XONSH
  chmod +x $XONSH
  echo "xonsh installed at:"
  echo "$XONSH"
  echo -e "\n launch with: xonsh"
fi

exit 0
