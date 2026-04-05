#!/bin/bash
USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
REPO_INSTALLS="$USER_HOME/Applications/repos"

mkdir -p $REPO_INSTALLS
cd $REPO_INSTALLS
git clone https://github.com/AlexsJones/llmfit.git
cd llmfit

# Build frontend assets
cd llmfit-web
npm ci && npm run build
cd ..

# Build from source and install to cargo PATH (~/.cargo/bin/llmfit)
cargo install --path llmfit-tui
