vim.keymap.set('n', '<leader>ad', ':Neotree filesystem reveal left<CR>')

require("neo-tree").setup({
  -- TODO: git_status周りの設定
  window = {
    mappings = {
      ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
    }
  },
  filesystem = {
    filtered_items = {
      visible = true,
      hide_hidden = false,
      hide_dotfiles = false,
      hide_by_name = { "node_modules", "vendor", ".git", ".cache", ".idea", ".vscode", ".DS_Store" },
    },
  },
})
