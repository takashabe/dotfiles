local opt = vim.opt
opt.number = true
opt.title = true
opt.cmdheight = 1
opt.termguicolors = true
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
-- 検索系
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
-- 括弧をハイライト表示
opt.showmatch = true
-- 括弧秒数を調整
opt.matchtime = 1
-- cmp 設定
opt.completeopt = { "menu", "menuone", "noselect" }
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
-- 制御文字を表示
opt.list = true
-- 制御文字をカスタマイズ
--[[
tab: タブ
trail: 行末（行最後の文字から改行まで）の半角スペース
eol: 改行
space: 半角スペース
extends: ウィンドウの幅が狭くて右に省略された文字がある記号
precedes: ウィンドウの幅が狭くて左に省略された文字がある記号
nbsp: 不可視のスペース]]
opt.listchars = {
  tab = " ",
  trail = "·",
  --eol = ""
}
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
--fold
opt.fillchars = { fold = " " }
opt.foldmethod = "indent"
opt.foldenable = false
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
--マウスの設定
vim.cmd.aunmenu({ "PopUp.How-to\\ disable\\ mouse" })
vim.cmd.aunmenu({ "PopUp.-1-" })
