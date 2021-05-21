" Start interactive EasyAlign in visual mode (e.g. vipga)
xnoremap <Leader>ga <Plug>(EasyAlign)

let g:easy_align_delimiters = {
\ ' ': {
\     'pattern': ' ',
\     'left_margin': 0,
\     'right_margin': 0,
\     'stick_to_left': 0,
\     'ignore_groups': ['!Comment']
\   }
\ }
