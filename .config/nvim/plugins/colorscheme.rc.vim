" colorscheme関連の設定値をまとめて管理する
let g:edge_style = 'neon'
let g:sonokai_style = 'andromeda'
let g:onedark_config = {
    \ 'style': 'cool',
\}

augroup colorscheme_setting
  au!
  autocmd User * hi CocMenuSel ctermfg=242 ctermbg=0 guifg=#2c2d30 guibg=#79b7eb guisp=none
augroup END
