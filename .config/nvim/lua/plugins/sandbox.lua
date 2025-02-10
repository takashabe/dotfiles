-- お試しプラグインを置く場所. プラグインの処遇が決まったらこのファイルから移動すること
return {
  -- 2025/01/15 align系で良さそう
  {
    'echasnovski/mini.align',
    config = function()
      require('mini.align').setup{
        mappings = {
          start = '<leader>ga',
          start_with_preview = '<leader>gA',
        },
      }
    end,
  },
  -- lspsaga
  {
    'nvimdev/lspsaga.nvim',
    config = function()
      require('lspsaga').setup({
        lightbulb = {
          sign = false, -- re-renderが走るのを抑制する
        },
      })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    },
  },
}
