return {
  -- colorschemes
  { "folke/tokyonight.nvim", opts = { styke = "moon" }, },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  }
}
