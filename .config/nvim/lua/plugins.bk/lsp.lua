return {
  -- lspconfig
  { "neovim/nvim-lspconfig", dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "bashls",
        "biome",
        "dockerls",
        "docker_compose_language_service",
        -- "gopls", 手動で入れる
        "golangci_lint_ls",
        "graphql",
        "lua_ls",
        "marksman",
        "tsserver",
        "sqlls",
        "yamlls",
        "terraformls",
      },
    },
  },

  -- cmdline tools and lsp servers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = { },
  },
}
