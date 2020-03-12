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
else
  call plug#begin('~/.vim/plugged')
  execute 'source' fnamemodify(expand('<sfile>'), ':h').'/plug.rc.vim'
  call plug#end()
endif

" apply .vimrc
execute 'source' fnamemodify(expand('<sfile>'), ':h').'/options.rc.vim'

" colorscheme
set background=dark
colorscheme gruvbox
