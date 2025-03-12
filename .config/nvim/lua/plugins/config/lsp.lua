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

-- vim.keymap.set('n', 'gr', '<cmd>Glance references<CR>')
-- vim.keymap.set('n', 'gd', '<cmd>Glance definitions<CR>')
-- vim.keymap.set('n', 'gi', '<cmd>Glance implementations<CR>')
-- vim.keymap.set('n', 'gt', '<cmd>Glance type_definitions<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

local capabilities = require('blink.cmp').get_lsp_capabilities()

lspconfig.gopls.setup({
  capabilities = capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = false,
      gofumpt = true,
      usePlaceholders = true,
      buildFlags = {
        "-tags=integration analytics_handler delivery_handler notification_handler segment_handler candidate_segment_handler overview_handler candidate_handler tenant_handler api_handler job_delivery_periodical_setting_handler free_delivery_periodical_setting_handler batch_periodical_free_delivery_handler job_handler email_communication_handler batch_handler webhook_handler batch_periodical_job_delivery_handler",
      },
    },
  },
})

lspconfig.sqls.setup({
  capabilities = capabilities,
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
