let g:fern#renderer = 'nerdfont'
" ドットファイルを表示する
let g:fern#default_hidden=1

nnoremap <leader>ad :Fern . -drawer -width=50 -reveal=%<CR>
