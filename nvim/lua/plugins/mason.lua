-- lua/plugins/mason.lua
return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      "ansible-language-server",
      "ansible-lint", -- optional but recommended
    },
  },
}
