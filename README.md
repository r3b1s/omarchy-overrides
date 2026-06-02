# Omarchy Overrides

Opinionated take on an opinionated distro.

An attempt at heavy customization that's easily updated and doesn't risk breaking the core system.

Always a work-in-progress.

## Neovim profiles

This repo currently contains three Neovim config directories:

- `nvim` - main `nvim` profile; layered on top of Omarchy's default `nvim` configuration (LazyVim starter) via `scripts/install/install-nvim`
- `nvim-notes` - notes-focused profile; launched via the `notes` alias and installed via `scripts/install/install-nvim-notes`
- `nvim-custom` - ground-up standalone profile for the `vim` alias; uses Neovim 0.12+ `vim.pack` instead of LazyVim or `lazy.nvim`, and installs via `scripts/install/install-nvim-custom`

Each Neovim config directory has its own `README.md` and `AGENTS.md` with more detail.

## Current project state

Some parts of this repo are currently stale.

In particular, setup and install scripts should not be assumed to work fully out of the box. Frequent Omarchy changes and recent Hyprland config migrations away from older Hyprlang-based syntax toward Lua have caused breakages over time, and some manual intervention is currently still expected.

Treat existing scripts and configs as useful starting points, not guaranteed fully-current automation.
