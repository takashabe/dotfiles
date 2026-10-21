local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

mason.setup()
mason_lspconfig.setup({
  ensure_installed = {},
  automatic_enable = true,
})

local ignored_filetypes_path = vim.fn.stdpath("state") .. "/lsp-install-ignored-filetypes.json"

local function read_ignored_filetypes()
  local ok, lines = pcall(vim.fn.readfile, ignored_filetypes_path)
  if not ok then
    return {}
  end
  local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  return decoded_ok and decoded or {}
end

local function ignore_filetype(ft)
  local ignored = read_ignored_filetypes()
  ignored[ft] = true
  vim.fn.writefile({ vim.json.encode(ignored) }, ignored_filetypes_path)
end

local function install_package(pkg)
  vim.notify("Installing " .. pkg.name .. "...")
  pkg:install({}, function(success, err)
    vim.schedule(function()
      if success then
        vim.notify(pkg.name .. " installed")
      else
        vim.notify("Failed to install " .. pkg.name .. ": " .. tostring(err), vim.log.levels.ERROR)
      end
    end)
  end)
end

local prompted_filetypes = {}
local ignore_choice = "(Don't ask again for this filetype)"

local function prompt_install_lsp(ft)
  if prompted_filetypes[ft] or read_ignored_filetypes()[ft] then
    return
  end
  local registry = require("mason-registry")
  local servers = mason_lspconfig.get_available_servers({ filetype = ft })
  if #servers == 0 then
    return
  end
  local lspconfig_to_package = mason_lspconfig.get_mappings().lspconfig_to_package
  local packages = {}
  for _, server in ipairs(servers) do
    local pkg = registry.get_package(lspconfig_to_package[server])
    if vim.lsp.is_enabled(server) or pkg:is_installed() or pkg:is_installing() then
      return
    end
    if not vim.tbl_contains(packages, pkg.name) then
      table.insert(packages, pkg.name)
    end
  end
  table.sort(packages)
  table.insert(packages, ignore_choice)

  prompted_filetypes[ft] = true
  vim.ui.select(packages, { prompt = "No LSP server for " .. ft .. ". Install with Mason?" }, function(choice)
    if choice == ignore_choice then
      ignore_filetype(ft)
    elseif choice then
      install_package(registry.get_package(choice))
    end
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end
    require("mason-registry").refresh(vim.schedule_wrap(function()
      prompt_install_lsp(args.match)
    end))
  end,
})

-- lspconfig v2
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = false,
      gofumpt = true,
      usePlaceholders = true,
      buildFlags = {
        "-tags=integration all_handler analytics_handler delivery_handler notification_handler segment_handler candidate_segment_handler overview_handler candidate_handler tenant_handler api_handler job_delivery_periodical_setting_handler free_delivery_periodical_setting_handler batch_periodical_free_delivery_handler job_handler email_communication_handler batch_handler webhook_handler batch_periodical_job_delivery_handler application_handler",
      },
    },
  },
})
vim.lsp.config("sqls", {
  on_attach = function(client, bufnr)
    require("sqls").on_attach(client, bufnr)
  end,
  settings = {
    sqls = {
      connections = {
        {
          driver = "postgresql",
          dataSourceName = "host=127.0.0.1 port=5432 user=postgres password=password dbname=postgres sslmode=disable",
        },
      },
    },
  },
})
vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      validate = true,
      completion = true,
    },
  },
})
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
-- vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format()<CR>')
vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
