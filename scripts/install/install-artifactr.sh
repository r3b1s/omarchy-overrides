#!/bin/bash
# one-liner
curl -fsSL https://raw.githubusercontent.com/reg1z/artifactr/main/install.sh | bash

echo "Attempting ssh git clone of llm-vaults"
cd ~/repos
git clone git@github.com:reg1z/llm-vaults.git

echo "END: install-artifactr.sh"
