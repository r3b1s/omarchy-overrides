local M = {}

local extra_packages = {
  "ansible-lint",
  "docker-compose-language-service",
}

function M.setup()
  require("mason").setup()

  require("mason-lspconfig").setup({
    ensure_installed = require("plugins.lsp").server_names(),
    automatic_enable = false,
  })

  vim.schedule(function()
    for _, package in ipairs(extra_packages) do
      vim.cmd("silent! MasonInstall " .. package)
    end
  end)
end

return M
