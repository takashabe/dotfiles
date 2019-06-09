" plugins configuration
let plug_conf = expand('<sfile>:p:h') . '/plugins/'

" ==========================================================
" Apppearance
" ==========================================================
Plug 'joshdick/onedark.vim'
Plug 'cocopon/iceberg.vim'
Plug 'itchyny/lightline.vim'
execute 'source' plug_conf . 'lightline.rc.vim'
Plug 'nathanaelkane/vim-indent-guides'
execute 'source' plug_conf . 'vim-indent-guides.rc.vim'
Plug 'ryanoasis/vim-devicons'
execute 'source' plug_conf . 'vim-devicons.rc.vim'

" ==========================================================
" Edit
" ==========================================================
Plug 'cohama/lexima.vim'
Plug 'junegunn/vim-easy-align'
execute 'source' plug_conf . 'vim-easy-align.rc.vim'
Plug 'scrooloose/nerdcommenter'
execute 'source' plug_conf . 'nerdcommenter.rc.vim'

" ==========================================================
" Window/Buffer
" ==========================================================
Plug 'mtth/scratch.vim'
execute 'source' plug_conf . 'scratch.rc.vim'
Plug 'scrooloose/nerdtree'
execute 'source' plug_conf . 'nerdtree.rc.vim'

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
Plug 'prabirshrestha/vim-lsp'
execute 'source' plug_conf . 'vim-lsp.rc.vim'

" ==========================================================
" Go
" ==========================================================
Plug 'fatih/vim-go', {'for': 'go'}
execute 'source' plug_conf . 'vim-go.rc.vim'

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

" ==========================================================
" VCS
" ==========================================================
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

" ==========================================================
" Others
" ==========================================================
Plug 'majutsushi/tagbar'
execute 'source' plug_conf . 'tagbar.rc.vim'
Plug 'w0rp/ale'
execute 'source' plug_conf . 'ale.rc.vim'
Plug 'direnv/direnv.vim'
