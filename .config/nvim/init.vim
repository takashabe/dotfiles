set nocompatible

augroup MyAutoCmd
  autocmd!
augroup END

" setting env. in order to use in plugin settings
let mapleader = ","
let $MYVIMRC="$HOME/.config/nvim/init.vim"

" install vim-plug
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

execute 'source' fnamemodify(expand('<sfile>'), ':h').'/plug.rc.vim'

call plug#end()

execute 'source' fnamemodify(expand('<sfile>'), ':h').'/options.rc.vim'
colorscheme onedark
