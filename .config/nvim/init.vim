set nocompatible

augroup MyAutoCmd
  autocmd!
augroup END

" setting env. in order to use in plugin settings
let mapleader = ","
let $MYVIMRC="$HOME/.config/nvim/init.vim"

" install vim-plug
if has('nvim')
  if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
          \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
else
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
          \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif

" load plugins
if has('nvim')
  call plug#begin('~/.local/share/nvim/plugged')
  execute 'source' fnamemodify(expand('<sfile>'), ':h').'/plug.rc.vim'
  call plug#end()

  " require after plug#end
  execute 'source' plug_conf . 'nvim-treesitter.rc.vim'
  luafile ~/.config/nvim/plugins/telescope.rc.lua
  luafile ~/.config/nvim/plugins/neoai.rc.lua
  " execute 'source' plug_conf . 'todo-comments.rc.vim' " todo-comments用
else
  call plug#begin('~/.vim/plugged')
  execute 'source' fnamemodify(expand('<sfile>'), ':h').'/plug.rc.vim'
  call plug#end()
endif

" apply .vimrc
execute 'source' fnamemodify(expand('<sfile>'), ':h').'/options.rc.vim'

" colorscheme
syntax enable
set background=dark

if has('nvim')
  colorscheme catppuccin-mocha
else
  colorscheme onedark
endif
