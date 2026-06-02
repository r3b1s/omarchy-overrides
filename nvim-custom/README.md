# nvim-custom

Standalone Neovim profile for the `vim` alias.

## Purpose
- Starts from the ground up instead of using the LazyVim starter.
- Uses Neovim 0.12+ built-in `vim.pack` for plugin management.
- Ports the requested local keymaps, options, completion, Mason, LSP, bullets, and Ansible behavior from the main config.

## Layout
- `init.lua` - entrypoint.
- `lua/config/options.lua` - editor options.
- `lua/config/keymaps.lua` - custom keymaps.
- `lua/config/pack.lua` - `vim.pack` plugin bootstrap and setup order.
- `lua/plugins/completion.lua` - `blink.cmp` setup without Tab / Shift-Tab bindings.
- `lua/plugins/mason.lua` - Mason and Mason LSP bootstrap.
- `lua/plugins/lsp.lua` - LSP server definitions and enablement.
- `lua/plugins/ansible.lua` - Ansible filetype detection rules.
- `lua/plugins/bullets.lua` - bullets.vim setup.

## Plugins
- `saghen/blink.lib`
- `saghen/blink.cmp`
- `mason-org/mason.nvim`
- `mason-org/mason-lspconfig.nvim`
- `neovim/nvim-lspconfig`
- `pearofducks/ansible-vim`
- `bullets-vim/bullets.vim`

## Install / run
- Install with: `scripts/install/install-nvim-custom`
- Run with: `vim`

## Notes
- This profile is standalone and does not clone any starter config.
- `vim.pack` manages plugins under Neovim's data directory.
- `blink.cmp` requires Neovim 0.12+ and is built via the `PackChanged` hook in `lua/config/pack.lua`.
