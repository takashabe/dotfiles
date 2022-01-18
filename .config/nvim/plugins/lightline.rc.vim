let g:lightline = {
      \ 'colorscheme': 'sonokai',
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['filename', 'gina_branch', 'method', 'lsp_warning', 'lsp_error'],
      \   ],
      \   'right': [
      \     ['fileformat', 'fileencoding', 'filetype'],
      \     ['lineinfo']
      \   ],
      \ },
      \ 'component_expand': {
      \   'lsp_warning': 'g:lightline.my.lsp_warning',
      \   'lsp_error': 'g:lightline.my.lsp_error',
      \ },
      \ 'component_function': {
      \   'mode': 'g:lightline.my.mode',
      \   'filename': 'g:lightline.my.filename',
      \   'fileformat': 'g:lightline.my.fileformat',
      \   'fileencoding': 'g:lightline.my.fileencoding',
      \   'filetype': 'g:lightline.my.filetype',
      \   'lineinfo': 'g:lightline.my.lineinfo',
      \   'gina_branch': 'g:lightline.my.gina_branch',
      \   'method': 'NearestMethodOrFunction'
      \ },
      \ 'component_type': {
      \   'lsp_warning': 'warning',
      \   'lsp_error': 'error',
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

function! g:lightline.my.lsp_warning() abort
  let l:counts = lsp#get_buffer_diagnostics_counts()
  return l:counts.warning == 0 ? '' : printf('W:%d', l:counts.warning)
endfunction

function! g:lightline.my.lsp_error() abort
  let l:counts = lsp#get_buffer_diagnostics_counts()
  return l:counts.error == 0 ? '' : printf('E:%d', l:counts.error)
endfunction

augroup lightline_autocmd
  autocmd!
  autocmd User lsp_diagnostics_updated call lightline#update()
augroup END

function! NearestMethodOrFunction() abort
  let l:func_name = get(b:, 'vista_nearest_method_or_function', '')
  if l:func_name != ''
    return ' ' . l:func_name
  endif
  return ''
endfunction
