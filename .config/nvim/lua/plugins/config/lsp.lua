local mason = require('mason')
local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')

mason.setup()
mason_lspconfig.setup({
  ensure_installed = {
    -- "gopls", 手動管理にする https://github.com/williamboman/mason.nvim/issues/1421
  },
})
mason_lspconfig.setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({})
  end,
})

vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

-- 共通設定
for _, server in ipairs(lspconfig.util.available_servers()) do
  lspconfig[server].setup({
    on_attach = function(client, bufnr)
      -- treesitterで担保されるため、semantic tokensを無効化する
      client.server_capabilities.semanticTokensProvider = nil
    end,
  })
end

lspconfig.gopls.setup({
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = false,
      gofumpt = true,
      usePlaceholders = true,
      buildFlags = {
        "-tags=delivery_handler notification_handler segment_handler overview_handler",
      },
    },
  },
})

lspconfig.sqls.setup({
  on_attach = function(client, bufnr)
    require('sqls').on_attach(client, bufnr)
  end,
  settings = {
    sqls = {
      connections = {
        {
          driver = 'postgresql',
          dataSourceName = 'host=127.0.0.1 port=5432 user=postgres password=password dbname=postgres sslmode=disable',
        },
      },
    },
  },
})
