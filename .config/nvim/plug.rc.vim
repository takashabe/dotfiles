" plugins configuration
let plug_conf = expand('<sfile>:p:h') . '/plugins/'

" ==========================================================
" Apppearance
" ==========================================================
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'ryanoasis/vim-devicons'
Plug 'micchy326/lightline-lsp-progress'
Plug 'itchyny/lightline.vim'
execute 'source' plug_conf . 'lightline.rc.vim'
Plug 'Yggdroot/indentLine'
execute 'source' plug_conf . 'indentLine.rc.vim'
Plug 'rafi/awesome-vim-colorschemes'

" ==========================================================
" Edit
" ==========================================================
Plug 'cohama/lexima.vim'
Plug 'junegunn/vim-easy-align'
execute 'source' plug_conf . 'vim-easy-align.rc.vim'
Plug 'scrooloose/nerdcommenter'
execute 'source' plug_conf . 'nerdcommenter.rc.vim'
Plug 'liuchengxu/vista.vim'

" for fcitx
if has('unix') && !has('mac')
  Plug 'fuenor/im_control.vim'
  execute 'source' plug_conf . 'im_control.rc.vim'
endif

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
" Process integration
" ==========================================================
Plug 'tpope/vim-dispatch'
Plug 'vim-test/vim-test'
execute 'source' plug_conf . 'vim-test.rc.vim'

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
Plug 'mattn/vim-goimports', {'for': 'go'}
execute 'source' plug_conf . 'vim-goimports.rc.vim'
Plug 'mattn/vim-goaddtags', {'for': 'go'}
Plug 'mattn/vim-gorun', {'for': 'go'}
Plug 'buoto/gotests-vim', {'for': 'go'}
execute 'source' plug_conf . 'gotests-vim.rc.vim'

" ==========================================================
" Other language/file syntax
" ==========================================================
Plug 'tokorom/vim-review', {'for': 'review'}
Plug 'rhysd/vim-gfm-syntax', {'for': 'markdown'}
Plug 'hashivim/vim-terraform', {'for': ['tf', 'tfvars']}
execute 'source' plug_conf . 'vim-terraform.rc.vim'
Plug 'cespare/vim-toml', {'for': 'toml'}
Plug 'dag/vim-fish', {'for': 'fish'}
Plug 'chr4/nginx.vim', {'for': 'nginx'}
Plug 'delphinus/vim-firestore'

" ==========================================================
" Others
" ==========================================================
Plug 'direnv/direnv.vim'
Plug 'haya14busa/vim-gtrans'
Plug 'lambdalisue/gina.vim'
