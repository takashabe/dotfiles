" plugins configuration
let plug_conf = expand('<sfile>:p:h') . '/plugins/'

" ==========================================================
" Apppearance
" ==========================================================
Plug 'joshdick/onedark.vim'
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

" ==========================================================
" fzf
" ==========================================================
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
execute 'source' plug_conf . 'fzf.rc.vim'

" ==========================================================
" LanguageServer
" ==========================================================
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
execute 'source' plug_conf . 'vim-lsp.rc.vim'

" ==========================================================
" Go
" ==========================================================
Plug 'fatih/vim-go', {'for': 'go', 'do': ':GoInstallBinaries'}
execute 'source' plug_conf . 'vim-go.rc.vim'

" ==========================================================
" Other language/file syntax
" ==========================================================
plug 'vim-toml', {'for': 'toml'}
plug 'vim-tmux', {'for': 'tmux'}

" ==========================================================
" Others
" ==========================================================
Plug 'tpope/vim-fugitive'
Plug 'majutsushi/tagbar'
execute 'source' plug_conf . 'tagbar.rc.vim'
Plug 'neomake/neomake'
execute 'source' plug_conf . 'neomake.rc.vim'
