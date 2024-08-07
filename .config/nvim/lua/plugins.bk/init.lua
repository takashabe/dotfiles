return {
  -- LSP
  { "neovim/nvim-lspconfig", dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- UI
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('plugins.config.lualine')
    end,
  },

  -- Util
  "nvim-lua/plenary.nvim",
}
