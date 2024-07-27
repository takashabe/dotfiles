vim.loader.enable()

-- leaderキーはlazy前に変更する
vim.g.mapleader = ","

require("core.options")
require("core.lazy")

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("core.lsp")
  end,
})
