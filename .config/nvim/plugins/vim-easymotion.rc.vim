nmap <Leader><Leader> [easymotion]
map [easymotion] <Plug>(easymotion-prefix)

" <Leader>f{char} to move to {char}
map  [easymotion]f <Plug>(easymotion-bd-f)
nmap [easymotion]f <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map [easymotion]L <Plug>(easymotion-bd-jk)
nmap [easymotion]L <Plug>(easymotion-overwin-line)

" Move to word
map  [easymotion]w <Plug>(easymotion-bd-w)
nmap [easymotion]w <Plug>(easymotion-overwin-w)
