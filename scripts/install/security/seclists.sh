#!/bin/bash
# Clones the latest version of the SecLists repository
# straight from the github source code.
#
# - https://github.com/danielmiessler/SecLists

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")

mkdir -p $USER_HOME/tools
cd $USER_HOME/tools
git clone --depth 1 https://github.com/danielmiessler/SecLists.git
mv SecLists seclists
