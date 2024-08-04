vim.keymap.set('n', '<leader>ad', ':Neotree filesystem reveal left<CR>')

require("neo-tree").setup({
  -- TODO: git_status周りの設定
  window = {
    mappings = {
      ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
    }
  }
})
