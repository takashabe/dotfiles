" plugins configuration
let plug_conf = expand('<sfile>:p:h') . '/plugins/'

" ==========================================================
" Apppearance
" ==========================================================
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'ryanoasis/vim-devicons'
Plug 'itchyny/lightline.vim'
execute 'source' plug_conf . 'lightline.rc.vim'
" Plug 'nathanaelkane/vim-indent-guides'
" execute 'source' plug_conf . 'vim-indent-guides.rc.vim'

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
Plug 'liuchengxu/vista.vim'
execute 'source' plug_conf . 'vista.rc.vim'

" ==========================================================
" Text Object
" ==========================================================
Plug 'tpope/vim-surround'

" ==========================================================
" Window/Buffer
" ==========================================================
Plug 'mtth/scratch.vim'
execute 'source' plug_conf . 'scratch.rc.vim'
Plug 'preservim/nerdtree'
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
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/vim-lsp'
execute 'source' plug_conf . 'vim-lsp.rc.vim'
Plug 'mattn/vim-lsp-settings'

" ==========================================================
" Go
" ==========================================================
Plug 'mattn/vim-goimports'
Plug 'mattn/vim-goaddtags'
Plug 'buoto/gotests-vim'
execute 'source' plug_conf . 'gotests-vim.rc.vim'

" ==========================================================
" Other language/file syntax
" ==========================================================
Plug 'tokorom/vim-review', {'for': 'review'}
Plug 'rhysd/vim-gfm-syntax', {'for': 'markdown'}
Plug 'iamcco/markdown-preview.nvim', {'for': 'markdown', 'do': 'cd app & yarn install'}
Plug 'hashivim/vim-terraform', {'for': ['tf', 'tfvars']}
execute 'source' plug_conf . 'vim-terraform.rc.vim'
Plug 'bazelbuild/vim-ft-bzl'
Plug 'cespare/vim-toml'
Plug 'dag/vim-fish'
Plug 'chr4/nginx.vim'

" ==========================================================
" VCS
" ==========================================================
Plug 'lambdalisue/gina.vim'

" ==========================================================
" Others
" ==========================================================
Plug 'majutsushi/tagbar'
execute 'source' plug_conf . 'tagbar.rc.vim'
Plug 'dense-analysis/ale'
execute 'source' plug_conf . 'ale.rc.vim'
Plug 'direnv/direnv.vim'
Plug 'haya14busa/vim-gtrans'
Plug 'sharat87/roast.vim'
