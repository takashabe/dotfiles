-- お試しプラグインを置く場所. プラグインの処遇が決まったらこのファイルから移動すること
return {
  -- 2025/01/15 align系で良さそう
  {
    'echasnovski/mini.align',
    config = function()
      require('mini.align').setup {
        mappings = {
          start = '<leader>ga',
          start_with_preview = '<leader>gA',
        },
      }
    end,
  },
}
