return {
  -- telescope
  {
    "nvim-telescope/telescope.nvim", dependencies = { 'nvim-lua/plenary.nvim', },
    config = function()
      require('plugins.config.telescope')
    end,
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('plugins.config.treesitter')
    end,
  },

  -- colorscheme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
}
