local mason = require('mason')
local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')

mason.setup()
mason_lspconfig.setup({
  ensure_installed = {
    "lua_ls",
    "rust_analyzer",
    -- "gopls", 手動管理にする https://github.com/williamboman/mason.nvim/issues/1421
    "golangci_lint_ls",
    "terraformls",
  },
})
mason_lspconfig.setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({})
  end,
})
