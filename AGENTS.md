# AGENTS

Read this file before making broad repo changes.

## Repo purpose

This repository contains personal Omarchy override files, helper scripts, and editor/system configuration used on a real machine. It is not a polished product repo; it is an actively used customization repo with some areas that have drifted over time.

## Current state

Parts of the repo are stale.

Especially important:
- setup/install scripts are **not** guaranteed to work out of the box
- some automation reflects older Omarchy behavior and may now require manual intervention
- recent Omarchy updates have caused breakages in existing overrides
- recent Hyprland changes, including migration pressure away from older Hyprlang-style configuration toward Lua-based config patterns in some areas, have also contributed to breakage and drift

Do **not** assume existing scripts are current just because they exist.

When working here, prefer documenting reality and making targeted fixes over assuming the original automation is still fully valid.

## Neovim configs

This repo currently has three Neovim config directories:
- `nvim` - main profile layered on top of LazyVim via `scripts/install/install-nvim`
- `nvim-notes` - notes profile layered on top of LazyVim via `scripts/install/install-nvim-notes`
- `nvim-custom` - standalone profile for the `vim` alias using Neovim 0.12+ `vim.pack`

Each of those directories contains its own `README.md` and `AGENTS.md`. Read the local `README.md` before editing that config.

## Omarchy / system config safety

This repo is for user overrides. When dealing with Omarchy-installed systems:
- exercise caution when this repo is *currently-installed & effective* on a real Omarchy distribution
- prefer editing user override locations and repo-managed files
- do not assume upstream Omarchy internals are stable across updates
- verify current behavior before changing install/setup logic
- avoid broad refactors unless the user explicitly asks for them
- be aware that this repo is intended to be installed in the user-specific `~/.local/share/omarchy-overrides/`.
  - this matches the official Omarchy repo's pattern -> the official Omarchy repo, also used for system configuration, is located at `~/.local/share/omarchy/`

## Working style

- Be conservative.
- Preserve user intent over architectural cleanup.
- Call out stale or uncertain areas plainly.
- Unless explicitly requested, do not try to repair all broken legacy setup flows in one pass.
