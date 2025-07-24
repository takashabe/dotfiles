vim.g.mapleader = ","

local opt = vim.opt
opt.number = true
opt.title = true
opt.cmdheight = 1
opt.updatetime = 100
opt.textwidth = 0
opt.signcolumn = "auto"
opt.background = "dark"
opt.clipboard = { "unnamed", "unnamedplus" }
-- tab時の見かけのスペース数
opt.tabstop = 2
-- 自動的に挿入される量
opt.shiftwidth = 2
-- 検索時の強調表示
opt.inccommand = "split"
-- Windowsでパスの区切り文字をスラッシュで扱う
-- 対応する括弧を強調表示
opt.showmatch = true
opt.matchtime = 1
opt.swapfile = false
opt.shadafile = "NONE"
opt.mouse = "a"
opt.fileencoding = "utf-8"
opt.spelllang = "en_us"
opt.fileformats = { "unix", "dos", "mac" }
-- 括弧をハイライト表示
opt.showmatch = true
-- 括弧秒数を調整
opt.matchtime = 1
-- cmp 設定
opt.completeopt = { "menuone", "popup", "noinsert" }
-- キーの待ち時間設定
opt.timeout = true
opt.timeoutlen = 300
-- インデント
opt.autoindent = true
opt.smartindent = true
-- 改行時にtabをスペースに変換
-- (インサート時に(Ctrl+v)+tabでtab挿入)
opt.expandtab = true
--行の改行を防ぐ
opt.linebreak = true
-- 制御文字
opt.list = true
opt.listchars = "tab:▸\\ ,trail:·,extends:→,precedes:←"

-- ノーマルモードから出るまでの時間を短縮
opt.ttimeoutlen = 1
-- 仮想編集を有効
opt.virtualedit = "onemore"
-- -エラー時の音を画面表示に
opt.visualbell = true
opt.wildignore =
  ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"
opt.fileencoding = "utf-8"
opt.termguicolors = true
-- 行を跨いで移動出来る様にする
opt.whichwrap = "b,s,h,l,[,],<,>,~"
-- undoの永続化
opt.undodir = vim.fn.stdpath("state")
opt.undofile = true
-- ファイル末尾の記号を消す
opt.fillchars:append("eob: ")
opt.helplang = { "ja", "en" }
opt.wrap = true
-- ステータスライン
opt.laststatus = 2
opt.cmdheight = 2
opt.ruler = true
-- カーソル行をハイライト
opt.cursorline = true

-- カーソルの形状設定
-- n: ノーマルモード (block)
-- v: ビジュアルモード (block)
-- i: インサートモード (vertical bar)
-- r: 置換モード (underscore)
-- c: コマンドラインモード (vertical bar)
-- t: ターミナルモード (vertical bar)
opt.guicursor = "n-v:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,t:ver25"

-- Alt-w でウインドウ移動出来るようにする
-- Terminalモードで<ESC>が他の機能に割り当てられている場合が多いため、Altを使う
vim.keymap.set("n", "<A-w>", "<C-w>w", { noremap = true, silent = true })
vim.keymap.set("i", "<A-w>", "<Esc><C-w>w", { noremap = true, silent = true })
vim.keymap.set("t", "<A-w>", "<C-\\><C-n><C-w>w", { noremap = true, silent = true })

-- ===============================
-- 検索
-- ===============================
-- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
opt.ignorecase = true
-- 検索文字列に大文字が含まれている場合は区別して検索する
opt.smartcase = true
-- 検索文字列入力時に順次対象文字列にヒットさせる
opt.incsearch = true
-- 検索時に最後まで行ったら最初に戻る
opt.wrapscan = true
-- 検索語をハイライト非表示
opt.hlsearch = true

-- ===============================
-- 編集関連
-- ===============================
-- yeでそのカーソル位置にある単語をレジスタに追加
vim.api.nvim_set_keymap("n", "ye", ':let @"=expand("<cword>")<CR>', { noremap = true, silent = true })
-- Visualモードでのpで選択範囲をレジスタの内容に置き換える
vim.api.nvim_set_keymap(
  "v",
  "p",
  '<Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>',
  { noremap = true, silent = true }
)
-- tabをスペースに変換して入力する
vim.opt.expandtab = true
-- ; と : を入れ替え
vim.api.nvim_set_keymap("n", ";", ":", { noremap = true })
vim.api.nvim_set_keymap("n", ":", ";", { noremap = true })
-- 末尾空白を削除
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- 保存/終了を簡単に
vim.api.nvim_set_keymap("n", "<Leader>w", ":w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>q", ":q<CR>", { noremap = true, silent = true })

-- ===============================
-- ファイルタイプ
-- ===============================
-- 特定のfiletypeではハードタブを使うようにする
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.go", "*.re", "*.tsv", "*.mk", "Makefile" },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

-- filetypeの設定
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.tf",
  command = "set filetype=terraform",
})
