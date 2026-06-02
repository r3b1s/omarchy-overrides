# nvim-notes

Notes-focused Neovim override set for the `nvim-notes` profile.

## Purpose
- Layers custom overrides on top of the LazyVim starter.
- Adds markdown and note-taking behavior for the notes workflow.
- Intended to be launched with `NVIM_APPNAME=nvim-notes nvim` or the `notes` alias.

## Layout
- `lua/config/keymaps.lua` - custom keymaps.
- `lua/config/options.lua` - custom editor options.
- `lua/plugins/notes.lua` - Obsidian and markdown rendering plugins.
- `lua/plugins/` - other plugin override files shared with the base profile.

## Install / run
- Install with: `scripts/install/install-nvim-notes`
- Run with: `notes`

## Notes
- This directory is not a full standalone config by itself.
- The install script first clones the LazyVim starter into `~/.config/nvim-notes`, then copies these overrides on top.
- Omarchy theme files are also wired in by the install script.
