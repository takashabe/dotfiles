return {
  -- LSP
  { "neovim/nvim-lspconfig", dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- Util
  "folke/persistence.nvim",
  { "nvim-lua/plenary.nvim", lazy = true },
}
