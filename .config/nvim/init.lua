vim.loader.enable()

-- leaderキーはlazy前に変更する
vim.g.mapleader = ","

require("core.options")
require("core.lazy")
-- require("core.lsp")

vim.cmd.colorscheme("catppuccin")
