" plugins configuration
let plug_conf = expand('<sfile>:p:h') . '/plugins/'

" ==========================================================
" Apppearance
" ==========================================================
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'

Plug 'itchyny/lightline.vim'
execute 'source' plug_conf . 'lightline.rc.vim'
Plug 'nathanaelkane/vim-indent-guides'
execute 'source' plug_conf . 'vim-indent-guides.rc.vim'

" ==========================================================
" Edit
" ==========================================================
Plug 'cohama/lexima.vim'
Plug 'junegunn/vim-easy-align'
execute 'source' plug_conf . 'vim-easy-align.rc.vim'
Plug 'scrooloose/nerdcommenter'
execute 'source' plug_conf . 'nerdcommenter.rc.vim'
Plug 'tpope/vim-capslock'
execute 'source' plug_conf . 'vim-capslock.rc.vim'
Plug 'fuenor/im_control.vim'
execute 'source' plug_conf . 'im_control.rc.vim'

" ==========================================================
" Text Object
" ==========================================================
Plug 'tpope/vim-surround'

" ==========================================================
" Window/Buffer
" ==========================================================
Plug 'mtth/scratch.vim'
execute 'source' plug_conf . 'scratch.rc.vim'
Plug 'lambdalisue/fern.vim'
execute 'source' plug_conf . 'fern.rc.vim'

" ==========================================================
" fzf
" ==========================================================
" require fzf binary
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
execute 'source' plug_conf . 'fzf.rc.vim'

" ==========================================================
" LanguageServer
" ==========================================================
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
" Plug 'prabirshrestha/vim-lsp'
Plug 'takashabe/vim-lsp' " temporary fork
execute 'source' plug_conf . 'vim-lsp.rc.vim'

" ==========================================================
" Go
" ==========================================================
Plug 'arp242/gopher.vim'
execute 'source' plug_conf . 'gopher.rc.vim'
Plug 'buoto/gotests-vim'
execute 'source' plug_conf . 'gotests-vim.rc.vim'

" ==========================================================
" Other language/file syntax
" ==========================================================
Plug 'cespare/vim-toml', {'for': 'toml'}
Plug 'keith/tmux.vim', {'for': 'tmux'}
Plug 'Glench/Vim-Jinja2-Syntax', {'for': 'jinja'}
Plug 'elzr/vim-json', {'for': 'json'}
Plug 'hail2u/vim-css3-syntax', {'for': 'css'}
Plug 'dag/vim-fish', {'for': 'fish'}
Plug 'rhysd/vim-gfm-syntax', {'for': 'markdown'}
Plug 'stephpy/vim-yaml', {'for': 'yaml'}
Plug 'tokorom/vim-review', {'for': 'review'}

" ==========================================================
" VCS
" ==========================================================
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'airblade/vim-gitgutter'

" ==========================================================
" Others
" ==========================================================
Plug 'majutsushi/tagbar'
execute 'source' plug_conf . 'tagbar.rc.vim'
Plug 'dense-analysis/ale'
execute 'source' plug_conf . 'ale.rc.vim'
Plug 'direnv/direnv.vim'
