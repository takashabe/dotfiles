let g:lightline = {
  \ 'colorscheme': 'solarized',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'inactive': {
  \   'left': [ [ 'filename' ] ],
  \   'right': [ [ 'fileinfo' ], [ 'percent' ] ]
  \ },
  \ 'component_function': {
  \   'mode': 'MyMode',
  \   'filename': 'MyFilename'
  \ }
  \ }
function! MyModified()
  return &ft =~ 'help\|vimfiler' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction
function! MyReadonly()
  return &ft !~? 'help\|vimfiler' && &readonly ? 'RO' : ''
endfunction
function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
  \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
  \  &ft == 'unite' ? unite#get_status_string() :
  \  &ft == 'vimshell' ? vimshell#get_status_string() :
  \ '' != expand('%') ? expand('%') : '[No Name]') .
  \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction
function! MyMode()
  if &ft == 'denite'
    " deniteは自分でinsertモード normalモードを管理しているので
    " lightlineのハイライト関数をdeniteのモードに合わせた値(-- NORMAL -- ならn)
    " にしてハイライト関数を呼ぶ
    let mode_str = substitute(denite#get_status_mode(), "-\\| ", "", "g")
    call lightline#link(tolower(mode_str[0]))
    return mode_str
  else
    return winwidth('.') > 60 ? lightline#mode() : ''
  endif
endfunction
