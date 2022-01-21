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
Plug 'Yggdroot/indentLine'
execute 'source' plug_conf . 'indentLine.rc.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'sainnhe/edge'
Plug 'sainnhe/sonokai'
Plug 'ray-x/aurora'
Plug 'olimorris/onedarkpro.nvim'
execute 'source' plug_conf . 'colorscheme.rc.vim'

" ==========================================================
" Edit
" ==========================================================
Plug 'cohama/lexima.vim'
Plug 'junegunn/vim-easy-align'
execute 'source' plug_conf . 'vim-easy-align.rc.vim'
Plug 'scrooloose/nerdcommenter'
execute 'source' plug_conf . 'nerdcommenter.rc.vim'
Plug 'liuchengxu/vista.vim'
execute 'source' plug_conf . 'vista.rc.vim'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
execute 'source' plug_conf . 'vim-vsnip.rc.vim'
Plug 'easymotion/vim-easymotion'
execute 'source' plug_conf . 'vim-easymotion.rc.vim'
Plug 'nicwest/vim-camelsnek'

" ==========================================================
" Text Object
" ==========================================================
Plug 'kana/vim-operator-user'
execute 'source' plug_conf . 'operator.rc.vim'
Plug 'tyru/operator-camelize.vim'
Plug 'tpope/vim-surround'

" ==========================================================
" Window/Buffer
" ==========================================================
Plug 'mtth/scratch.vim'
execute 'source' plug_conf . 'scratch.rc.vim'
Plug 'lambdalisue/fern.vim'
execute 'source' plug_conf . 'fern.rc.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'

" ==========================================================
" Process integration
" ==========================================================
Plug 'tpope/vim-dispatch'
Plug 'vim-test/vim-test'
execute 'source' plug_conf . 'vim-test.rc.vim'

" ==========================================================
" fzf
" ==========================================================
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
execute 'source' plug_conf . 'fzf.rc.vim'
Plug 'yuki-yano/fzf-preview.vim', { 'branch': 'release/rpc' }
execute 'source' plug_conf . 'fzf-preview.rc.vim'

" ==========================================================
" LanguageServer
" ==========================================================
if has('nvim')
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  execute 'source' plug_conf . 'coc.rc.vim'
else
  Plug 'prabirshrestha/asyncomplete.vim'
  Plug 'prabirshrestha/asyncomplete-lsp.vim'
  Plug 'prabirshrestha/vim-lsp'
  execute 'source' plug_conf . 'vim-lsp.rc.vim'
  Plug 'mattn/vim-lsp-settings'
end

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
" JavaScript
" ==========================================================
" TODO: lspに変えたい
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'graphql', 'vue', 'html'] }

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
Plug 'delphinus/vim-firestore', {'for': 'rule'}
Plug 'mechatroner/rainbow_csv', {'for': ['csv', 'tsv']}
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'jparise/vim-graphql'
if has('nvim')
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
end

" ==========================================================
" Git
" ==========================================================
Plug 'lambdalisue/gina.vim'
Plug 'tpope/vim-fugitive'
Plug 'tyru/open-browser.vim'
Plug 'tyru/open-browser-github.vim'
Plug 'airblade/vim-gitgutter'

" ==========================================================
" Others
" ==========================================================
Plug 'direnv/direnv.vim'
if has('nvim')
  Plug 'utahta/trans.nvim', {'do': 'make'}
  execute 'source' plug_conf . 'trans.rc.vim'
else
  Plug 'haya14busa/vim-gtrans'
end
