local mason = require("mason")
local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")

local capabilities = require("blink.cmp").get_lsp_capabilities()

-- 固有の設定を持つサーバ群
local server_settings = {
  gopls = {
    settings = {
      capabilities = capabilities,
      gopls = {
        analyses = { unusedparams = true },
        staticcheck = false,
        gofumpt = true,
        usePlaceholders = true,
        buildFlags = {
          "-tags=integration analytics_handler delivery_handler notification_handler segment_handler candidate_segment_handler overview_handler candidate_handler tenant_handler api_handler job_delivery_periodical_setting_handler free_delivery_periodical_setting_handler batch_periodical_free_delivery_handler job_handler email_communication_handler batch_handler webhook_handler batch_periodical_job_delivery_handler",
        },
      },
    },
  },
  sqls = {
    on_attach = function(client, bufnr)
      require("sqls").on_attach(client, bufnr)
    end,
    settings = {
      capabilities = capabilities,
      sqls = {
        connections = {
          {
            driver = "postgresql",
            dataSourceName = "host=127.0.0.1 port=5432 user=postgres password=password dbname=postgres sslmode=disable",
          },
        },
      },
    },
  },
  yamlls = {
    settings = {
      capabilities = capabilities,
      yaml = {
        schemaStore = {
          enable = true,
          url = "https://www.schemastore.org/api/json/catalog.json",
        },
        validate = true,
        completion = true,
      },
    },
  },
}

-- Masonのセットアップ
mason.setup()
mason_lspconfig.setup({
  ensure_installed = {},
  automatic_enable = true,
  handlers = {
    function(server_name)
      -- サーバー固有の設定があればそれを使用、なければデフォルト設定
      local server = server_settings[server_name] or { capabilities = capabilities }
      lspconfig[server_name].setup(server)
    end,
  },
})

vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
-- vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format()<CR>')
vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
