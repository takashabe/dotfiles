return {
  -- colorschemes
  { "ellisonleao/gruvbox.nvim" },
  { "folke/tokyonight.nvim", opts = { styke = "moon" }, },
  { "catppuccin/nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  }
}
