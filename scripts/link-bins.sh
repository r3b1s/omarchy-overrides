#!/usr/bin/env bash

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
DOTS="$USER_HOME/.local/share/omarchy-overrides"
DOTS_BIN="$DOTS/bin"
LOCAL_BIN="$USER_HOME/.local/bin"

chmod 755 $DOTS_BIN/*
mkdir -p "$LOCAL_BIN"

for f in "$DOTS_BIN"/*; do
  file=$(basename "$f")
  echo "Linking $file..."
  rm -v "$LOCAL_BIN"/"$file"
  ln -s -v "$DOTS_BIN"/"$file" "$LOCAL_BIN"/"$file"
done

echo "END: link-bins.sh"
