" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap <Leader>ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap <Leader>ga <Plug>(EasyAlign)

let g:easy_align_delimiters = {
\ ' ': {
\     'pattern': ' ',
\     'left_margin': 0,
\     'right_margin': 0,
\     'stick_to_left': 0,
\     'ignore_groups': ['!Comment']
\   }
\ }
