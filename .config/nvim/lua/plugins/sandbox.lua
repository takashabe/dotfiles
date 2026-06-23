-- お試しプラグインを置く場所. プラグインの処遇が決まったらこのファイルから移動すること
return {
  {
    "Wansmer/treesj",
    keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
    config = function()
      require("treesj").setup({--[[ your config ]]
      })
    end,
  },
}
