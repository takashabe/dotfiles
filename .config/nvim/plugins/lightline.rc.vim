let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['filename', 'gina_branch'],
      \   ],
      \   'right': [
      \     ['fileformat', 'fileencoding', 'filetype'],
      \     ['lineinfo']
      \   ],
      \ },
      \ 'inactive': {
      \   'left': [
      \     ['filename'],
      \   ],
      \ },
      \ 'component_function': {
      \   'mode':         'g:lightline.my.mode',
      \   'filename':     'g:lightline.my.filename',
      \   'fileformat':   'g:lightline.my.fileformat',
      \   'fileencoding': 'g:lightline.my.fileencoding',
      \   'filetype':     'g:lightline.my.filetype',
      \   'lineinfo':     'g:lightline.my.lineinfo',
      \   'gina_branch':  'g:lightline.my.gina_branch',
      \   'gina_traffic': 'g:lightline.my.gina_traffic',
      \   'gina_status':  'g:lightline.my.gina_status',
      \ },
      \}

" Note:
" component_function cannot be a script local function so use
" g:lightline.my namespace instead of s:
let g:lightline.my = {}

  function! g:lightline.my.mode() abort
    return &filetype !~# 'vimfiler' ? lightline#mode() : ''
  endfunction

  function! g:lightline.my.readonly() abort
    return empty(&buftype) && &readonly ? "RO" : ''
  endfunction

  function! g:lightline.my.modified() abort
    return empty(&buftype) && &modified ? "+" : ''
  endfunction

  function! g:lightline.my.filename() abort
    let fname = fnamemodify(expand('%'), ':~:.')
    let readonly = g:lightline.my.readonly()
    let modified = g:lightline.my.modified()
    return '' .
          \ (empty(fname)    ? '[No name]' : fname) .
          \ (empty(readonly) ? '' : ' ' . readonly) .
          \ (empty(modified) ? '' : ' ' . modified)
  endfunction

  function! g:lightline.my.fileformat() abort
    return &filetype !~# 'vimfiler' ? &fileformat: ''
  endfunction

  function! g:lightline.my.filetype() abort
    return &filetype !~# 'vimfiler' ? (strlen(&filetype) ? &filetype: 'no ft') : ''
  endfunction

  function! g:lightline.my.fileencoding() abort
    return &filetype !~# 'vimfiler' ? (strlen(&fileencoding) ? &fileencoding : &encoding) : ''
  endfunction

  function! g:lightline.my.lineinfo() abort
    return &filetype !~# 'vimfiler' && winwidth(0) >= 70 ? printf("L:%3d/%3d C:%d", line('.'), line('$'), col('.')) : ''
  endfunction

  function! g:lightline.my.gina_branch() abort
    return gina#component#repo#branch()
  endfunction
