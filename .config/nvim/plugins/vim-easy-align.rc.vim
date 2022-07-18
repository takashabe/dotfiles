" Start interactive EasyAlign in visual mode (e.g. vipga)
xnoremap <Leader>ga <Plug>(EasyAlign)
" 整列対象はコメント、文字列を含めて全て対象とする
" コメントなどを除外したいときは C-g すること
let g:easy_align_ignore_groups = []
let g:easy_align_delimiters = {
\ ' ': {
\     'pattern': ' ',
\     'left_margin': 0,
\     'right_margin': 0,
\     'stick_to_left': 0
\   }
\ }
