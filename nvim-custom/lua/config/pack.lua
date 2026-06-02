local gh = function(repo)
  return "https://github.com/" .. repo
end

require("plugins.ansible").pre_setup()
require("plugins.bullets").setup()

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("nvim_custom_pack", { clear = true }),
  callback = function(ev)
    local spec = ev.data and ev.data.spec or nil
    local kind = ev.data and ev.data.kind or nil
    if not spec or spec.name ~= "blink.cmp" then
      return
    end
    if kind ~= "install" and kind ~= "update" then
      return
    end
    if not ev.data.active then
      vim.cmd.packadd("blink.cmp")
    end
    require("blink.cmp").build():pwait()
  end,
})

vim.pack.add({
  gh("saghen/blink.lib"),
  gh("saghen/blink.cmp"),
  gh("mason-org/mason.nvim"),
  gh("mason-org/mason-lspconfig.nvim"),
  gh("neovim/nvim-lspconfig"),
  gh("pearofducks/ansible-vim"),
  gh("bullets-vim/bullets.vim"),
})

require("plugins.completion").setup()
require("plugins.ansible").setup()
require("plugins.lsp").setup()
require("plugins.mason").setup()
