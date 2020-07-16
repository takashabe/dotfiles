"let g:lightline = {
"      \ 'colorscheme': 'onedark',
"      \ 'mode_map': {'c': 'NORMAL'},
"      \ 'active': {
"      \   'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'filename', 'modified', 'method'] ]
"      \ },
"      \ 'component_function': {
"      \   'modified': 'LightlineModified',
"      \   'readonly': 'LightlineReadonly',
"      \   'gitbranch': 'LightlineGitBranch',
"      \   'filename': 'LightlineFilename',
"      \   'fileformat': 'LightlineFileformat',
"      \   'filetype': 'LightlineFiletype',
"      \   'fileencoding': 'LightlineFileencoding',
"      \   'mode': 'LightlineMode'
"      \ }
"      \ }

let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['filename'],
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
      \ 'tabline': {
      \   'left': [
      \     ['cwd'],
      \     ['tabs'],
      \   ],
      \   'right': [
      \     ['gina_branch', 'gina_traffic', 'gina_status'],
      \   ]
      \ },
      \ 'component_function': {
      \   'mode':         'g:lightline.my.mode',
      \   'cwd':          'g:lightline.my.cwd',
      \   'filename':     'g:lightline.my.filename',
      \   'fileformat':   'g:lightline.my.fileformat',
      \   'fileencoding': 'g:lightline.my.fileencoding',
      \   'filetype':     'g:lightline.my.filetype',
      \   'lineinfo':     'g:lightline.my.lineinfo',
      \   'gina_branch':  'g:lightline.my.gina_branch',
      \   'gina_traffic': 'g:lightline.my.gina_traffic',
      \   'gina_status':  'g:lightline.my.gina_status',
      \ },
      \ 'separator': {'left': "\ue0b0", 'right': "\ue0b2"},
      \ 'subseparator': {'left': "\ue0b1", 'right': "\ue0b3"},
      \}

" Note:
" component_function cannot be a script local function so use
" g:lightline.my namespace instead of s:
let g:lightline.my = {}

  function! g:lightline.my.mode() abort
    return &filetype !~# 'vimfiler' ? lightline#mode() : ''
  endfunction

  function! g:lightline.my.cwd() abort
    return fnamemodify(getcwd(), ':~')
  endfunction

  function! g:lightline.my.readonly() abort
    return empty(&buftype) && &readonly ? "\ue0a2" : ''
  endfunction

  function! g:lightline.my.modified() abort
    return empty(&buftype) && &modified ? "\uf41e" : ''
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
    return &filetype !~# 'vimfiler' ? &fileformat . ' ' . WebDevIconsGetFileFormatSymbol() : ''
  endfunction

  function! g:lightline.my.filetype() abort
    return &filetype !~# 'vimfiler' ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
  endfunction

  function! g:lightline.my.fileencoding() abort
    return &filetype !~# 'vimfiler' ? (strlen(&fileencoding) ? &fileencoding : &encoding) : ''
  endfunction

  function! g:lightline.my.lineinfo() abort
    return &filetype !~# 'vimfiler' && winwidth(0) >= 70 ? printf("\ue0a1% 3d / %d \ue0a3% 3d", line('.'), line('$'), col('.')) : ''
  endfunction

  function! g:lightline.my.gina_branch() abort
    return gina#component#repo#preset('fancy')
  endfunction

  function! g:lightline.my.gina_traffic() abort
    return gina#component#status#preset('fancy')
  endfunction

  function! g:lightline.my.gina_status() abort
    return gina#component#traffic#preset('fancy')
  endfunction
