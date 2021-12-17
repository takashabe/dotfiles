"-------------------------------------------------------------------------------
" 基本設定 Basics
"-------------------------------------------------------------------------------
set nocompatible                 " vi互換なし
set scrolloff=5                  " スクロール時の余白確保
set textwidth=0                  " 一行に長い文章を書いていても自動折り返しをしない
set nobackup                     " バックアップ取らない
set autoread                     " 他で書き換えられたら自動で読み直す
set noswapfile                   " スワップファイル作らない
set hidden                       " 編集中でも他のファイルを開けるようにする
set backspace=indent,eol,start   " バックスペースでなんでも消せるように
set formatoptions=lmoq           " テキスト整形オプション，マルチバイト系を追加
set vb t_vb=                     " ビープをならさない
set browsedir=buffer             " Exploreの初期ディレクトリ
set whichwrap=b,s,h,l,<,>,[,]    " カーソルを行頭、行末で止まらないようにする
set showcmd                      " コマンドをステータス行に表示
set showmode                     " 現在のモードを表示
set viminfo='50,<1000,s100,\"50  " viminfoファイルの設定
set modeline                     " モードラインを有効にする
set modelines=1                  " モードラインは1行
set noundofile                   " undofileを作らない

" OSのクリップボードを使用する
if has('mac')
  set clipboard=unnamed
  let g:yankring_clipboard_monitor=0
else
  set clipboard=unnamedplus
endif

" Ev/Rvでvimrcの編集と反映
command! Ev edit $MYVIMRC
command! Rv source $MYVIMRC

" マウスを有効にする
set mouse=a

" 保存/終了を簡単に
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>

" nvimでマルチバイト文字の入力が文字化けしないように
" https://github.com/neovim/neovim/issues/3094
if has('nvim')
  set ttimeout
  set ttimeoutlen=50
endif

"-------------------------------------------------------------------------------
" ステータスライン StatusLine
"-------------------------------------------------------------------------------
set laststatus=2 " 常にステータスラインを表示

"カーソルが何行目の何列目に置かれているかを表示する
set ruler

"ステータスラインに文字コードと改行文字を表示する
if winwidth(0) >= 120
  set statusline=%<[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ %F%=[%{GetB()}]\ %l,%c%V%8P
else
  set statusline=%<[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ %f%=[%{GetB()}]\ %l,%c%V%8P
endif

"入力モード時、ステータスラインのカラーを変更
augroup InsertHook
  autocmd!
  autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340 ctermfg=cyan
  autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90 ctermfg=white
augroup END

"自動的に QuickFix リストを表示する
augroup Quickfix
  autocmd!
  autocmd QuickfixCmdPost make,grep,grepadd,vimgrep,vimgrepadd cwin
  autocmd QuickfixCmdPost lmake,lgrep,lgrepadd,lvimgrep,lvimgrepadd lwin
augroup END

function! GetB()
  let c = matchstr(getline('.'), '.', col('.') - 1)
  let c = iconv(c, &enc, &fenc)
  return String2Hex(c)
endfunction
" help eval-examples
" The function Nr2Hex() returns the Hex string of a number.
func! Nr2Hex(nr)
  let n = a:nr
  let r = ""
  while n
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
  endwhile
  return r
endfunc
" The function String2Hex() converts each character in a string to a two
" character Hex string.
func! String2Hex(str)
  let out = ''
  let ix = 0
  while ix < strlen(a:str)
    let out = out . Nr2Hex(char2nr(a:str[ix]))
    let ix = ix + 1
  endwhile
  return out
endfunc

"-------------------------------------------------------------------------------
" 表示 Apperance
"-------------------------------------------------------------------------------
set showmatch         " 括弧の対応をハイライト
set number            " 行番号表示
set list              " 不可視文字表示
set listchars=tab:»-,trail:-,extends:»,precedes:<,eol:↲ " 不可視文字の表示形式
set display=uhex      " 印字不可能文字を16進数で表示

"" カーソル行をハイライト
set cursorline
"" カレントウィンドウにのみ罫線を引く
augroup cch
 autocmd! cch
 autocmd WinLeave * set nocursorline
 autocmd WinEnter,BufRead * set cursorline
augroup END

" insertモードとnormalモードでカーソルを切り替える
if !has('gui_running') && !has('nvim')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
endif

hi clear CursorLine
hi CursorLine ctermbg=black gui=underline guibg=black

" コマンド実行中は再描画しない
set lazyredraw
" 高速ターミナル接続を行う
set ttyfast

" コマンドラインの高さ
set cmdheight=2

" vsplit時のスクロールを高速化する
if has("vim_starting") && !has('gui_running') && has('vertsplit')
  function! EnableVsplitMode()
    " enable origin mode and left/right margins
    let &t_CS = "y"
    let &t_ti = &t_ti . "\e[?6;69h"
    let &t_te = "\e[?6;69l\e[999H" . &t_te
    let &t_CV = "\e[%i%p1%d;%p2%ds"
    call writefile([ "\e[?6;69h" ], "/dev/tty", "a")
  endfunction

  " old vim does not ignore CPR
  map <special> <Esc>[3;9R <Nop>

  " new vim can't handle CPR with direct mapping
  " map <expr> ^[[3;3R EnableVsplitMode()
  set t_F9=[3;3R
  map <expr> <t_F9> EnableVsplitMode()
  let &t_RV .= "\e[?6;69h\e[1;3s\e[3;9H\e[6n\e[0;0s\e[?6;69l"
endif

"-------------------------------------------------------------------------------
" インデント Indent
"-------------------------------------------------------------------------------
set autoindent   " 自動でインデント
set smartindent  " 新しい行を開始したときに、新しい行のインデントを現在行と同じ量にする。
set cindent      " Cプログラムファイルの自動インデントを始める

" softtabstopはTabキー押し下げ時の挿入される空白の量，0の場合はtabstopと同じ，BSにも影響する
set tabstop=2 shiftwidth=2 softtabstop=0

"ファイルタイプの検索を有効にする
filetype plugin on
"そのファイルタイプにあわせたインデントを利用する
filetype indent on

augroup FileTypeIndent
  autocmd!
  autocmd FileType html :set indentexpr=
  autocmd FileType xhtml :set indentexpr=
augroup END

"-------------------------------------------------------------------------------
" 補完・履歴 Complete
"-------------------------------------------------------------------------------
set wildmenu               " コマンド補完を強化
set wildchar=<tab>         " コマンド補完を開始するキー
set wildmode=list:full     " リスト表示，最長マッチ
set history=1000           " コマンド・検索パターンの履歴数
set complete+=k            " 補完に辞書ファイル追加
set completeopt-=preview   " 補完時にスクラッチウィンドウを表示しない

" C-spaceでC-x補完を出す
if has('nvim')
  " coc#refreshに譲る
  " inoremap <C-space> <C-x>
else
  inoremap <C-@> <C-x>
end

"-------------------------------------------------------------------------------
" 検索設定 Search
"-------------------------------------------------------------------------------
set wrapscan   " 最後まで検索したら先頭へ戻る
set ignorecase " 大文字小文字無視
set smartcase  " 検索文字列に大文字が含まれている場合は区別して検索する
set incsearch  " インクリメンタルサーチ
set hlsearch   " 検索文字をハイライト
"Escの2回押しでハイライト消去
nmap <ESC><ESC> ;nohlsearch<CR><ESC>

"選択した文字列を検索
vnoremap <silent> // y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>
"選択した文字列を置換
vnoremap /r "xy;%s/<C-R>=escape(@x, '\\/.*$^~[]')<CR>//gc<Left><Left><Left>

"s*置換後文字列/g<Cr>でカーソル下のキーワードを置換
nnoremap <expr> s* ':%substitute/\<' . expand('<cword>') . '\>/'

" :Gb <args> でGrepBufferする
command! -nargs=1 Gb :GrepBuffer <args>
" カーソル下の単語をGrepBufferする
nnoremap <C-g><C-b> :<C-u>GrepBuffer<Space><C-r><C-w><Enter>

" カーソル位置を検索したとき次の候補に移動させない
nnoremap * *N
nnoremap # *n

"-------------------------------------------------------------------------------
" 移動設定 Move
"-------------------------------------------------------------------------------
" カーソルを表示行で移動する。論理行移動は<C-n>,<C-p>
nnoremap j gj
nnoremap k gk

" 前回終了したカーソル行に移動
augroup Move
  autocmd!
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
augroup END

" 最後に編集された位置に移動
nnoremap gb '[
nnoremap gp ']

" 対応する括弧に移動
nnoremap [ %
nnoremap ] %

" カーソル位置の単語をyankする
nnoremap vy vawy

" 矩形選択で自由に移動する
set virtualedit+=block

"ビジュアルモード時vで行末まで選択
vnoremap v $h

" コマンドラインモード時の移動をEmacs風にする
" 行頭へ移動
cnoremap <C-a> <Home>
" 一文字戻る
cnoremap <C-b> <Left>
" カーソルの下の文字を削除
cnoremap <C-d> <Del>
" 行末へ移動
cnoremap <C-e> <End>
" 一文字進む
cnoremap <C-f> <Right>
" コマンドライン履歴を一つ進む
cnoremap <C-n> <Down>
" コマンドライン履歴を一つ戻る
cnoremap <C-p> <Up>
" 前の単語へ移動
cnoremap <M-b> <S-Left>
" 次の単語へ移動
cnoremap <M-f> <S-Right>

"-------------------------------------------------------------------------------
" エンコーディング関連 Encoding
"-------------------------------------------------------------------------------
set ffs=unix,dos,mac  " 改行文字
set encoding=utf-8    " デフォルトエンコーディング

" 文字コード関連
" -> banyan/recognize_charcode.vim

augroup FileEncoding
  autocmd!
  " cvsの時は文字コードをeuc-jpに設定
  autocmd FileType cvs :set fileencoding=euc-jp
  " 以下のファイルの時は文字コードをutf-8に設定
  autocmd FileType svn :set fileencoding=utf-8
  autocmd FileType js :set fileencoding=utf-8
  autocmd FileType css :set fileencoding=utf-8
  autocmd FileType html :set fileencoding=utf-8
  autocmd FileType xml :set fileencoding=utf-8
  autocmd FileType java :set fileencoding=utf-8
  autocmd FileType scala :set fileencoding=utf-8
  autocmd FileType go :set fileencoding=utf-8
augroup END

" ワイルドカードで表示するときに優先度を低くする拡張子
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" 指定文字コードで強制的にファイルを開く
command! Cp932 edit ++enc=cp932
command! Eucjp edit ++enc=euc-jp
command! Iso2022jp edit ++enc=iso-2022-jp
command! Utf8 edit ++enc=utf-8
command! Jis Iso2022jp
command! Sjis Cp932

"-------------------------------------------------------------------------------
" カラー関連 Colors
"-------------------------------------------------------------------------------
" ターミナルタイプによるカラー設定
if &term =~ "xterm-256color" || "screen-256color"
  " 256色
  set t_Co=256
  set t_Sf=[3%dm
  set t_Sb=[4%dm
elseif &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
  set t_Co=16
  set t_Sf=[3%dm
  set t_Sb=[4%dm
elseif &term =~ "xterm-color"
  set t_Co=8
  set t_Sf=[3%dm
  set t_Sb=[4%dm
endif

" truecolor
if has('patch-7.4.1778')
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
if has('nvim')
  set termguicolors
endif

" .nvimのsyntaxをvimに
au MyAutoCmd BufNewFile,BufRead *.nvim :set syntax=vim

"ポップアップメニューのカラーを設定
hi Pmenu guibg=#666666
hi PmenuSel guibg=#8cd0d3 guifg=#666666
hi PmenuSbar guibg=#333333

" ハイライト on
syntax enable

" 補完候補の色づけ for vim7
hi PmenuSel cterm=reverse ctermfg=33 ctermbg=222 gui=reverse guifg=#3399ff guibg=#f0e68c

"-------------------------------------------------------------------------------
" 編集関連 Edit
"-------------------------------------------------------------------------------

" yeでそのカーソル位置にある単語をレジスタに追加
nmap ye ;let @"=expand("<cword>")<CR>
" Visualモードでのpで選択範囲をレジスタの内容に置き換える
vnoremap p <Esc>;let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" :Ptでインデントモード切替
command! Pt :set paste!

" tabをスペースに変換して入力する
set expandtab

" ; と : を入れ替え
noremap ; :
noremap : ;

" C-h で <BS> を入力する
imap <C-h> <BS>
cmap <C-h> <BS>

" 末尾空白を削除
autocmd BufWritePre * :%s/\s\+$//e

" 特定のfiletypeではハードタブを使うようにする
au BufNewFile,BufRead *.go set noexpandtab tabstop=2 shiftwidth=2
au BufNewFile,BufRead *.re set noexpandtab tabstop=2 shiftwidth=2
au BufNewFile,BufRead *.tsv set noexpandtab tabstop=2 shiftwidth=2

"-------------------------------------------------------------------------------
" ターミナル Terminal
"-------------------------------------------------------------------------------
set sh=fish
tnoremap <silent> <C-q> <C-\><C-n>
if has('nvim')
  autocmd TermOpen * setlocal nonumber norelativenumber
  nnoremap <silent> <Leader>t :split term://fish<CR>:startinsert<CR>
else
  nnoremap <silent> <Leader>t :term<CR>
endif

"-------------------------------------------------------------------------------
" Noevim Provider
"-------------------------------------------------------------------------------
if has('nvim')
  " python
  let g:python_host_prog = '/usr/local/bin/python2'
  let g:python3_host_prog = '/usr/local/bin/python3'
endif
