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

-- vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
-- vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
-- vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
-- vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
-- vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
-- vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
-- vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
-- vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
-- vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
-- vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
-- vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
-- vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

-- lspsaga前提のキーマッピング
vim.keymap.set("n", "K",  "<cmd>Lspsaga hover_doc<CR>", { silent = true, desc = "Show Hover Documentation (Lspsaga)" })
vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>", { silent = true, desc = "Find References (Lspsaga)" })
vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { silent = true, desc = "Go to Definition (Lspsaga)" })
vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { silent = true, desc = "Go to Declaration" }) -- `lspsaga` に相当機能なし
vim.keymap.set("n", "gi", "<cmd>Lspsaga finder <CR>", { silent = true, desc = "Find Implementations (Lspsaga)" })
vim.keymap.set("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>", { silent = true, desc = "Go to Type Definition (Lspsaga)" })
vim.keymap.set("n", "gn", "<cmd>Lspsaga rename<CR>", { silent = true, desc = "Rename Symbol (Lspsaga)" })
vim.keymap.set("n", "ga", "<cmd>Lspsaga code_action<CR>", { silent = true, desc = "Show Code Actions (Lspsaga)" })
vim.keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true, desc = "Show Line Diagnostics (Lspsaga)" })
vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", { silent = true, desc = "Format Code" }) -- `lspsaga` にはフォーマット機能なし
vim.keymap.set("n", "g]", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true, desc = "Next Diagnostic (Lspsaga)" })
vim.keymap.set("n", "g[", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true, desc = "Previous Diagnostic (Lspsaga)" })
vim.keymap.set("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", { silent = true, desc = "Incoming Calls (Lspsaga)" }) -- 呼び出し元を表示する(lspsaga用)
vim.keymap.set("n", "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>", { silent = true, desc = "Outgoing Calls (Lspsaga)" }) -- 呼び出し先を表示する(lspsaga用)
vim.keymap.set("n", "<leader>fs", "<cmd>Lspsaga outline<CR>", { silent = true, desc = "Show Outline (Lspsaga)" })

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
        "-tags=delivery_handler notification_handler segment_handler overview_handler candidate_handler tenant_handler api_handler job_delivery_periodical_setting_handler free_delivery_periodical_setting_handler batch_periodical_free_delivery_handler job_handler email_communication_handler batch_handler",
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
