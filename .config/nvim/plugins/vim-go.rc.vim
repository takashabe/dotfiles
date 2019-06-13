" Formatter
let g:go_fmt_autosave = 1
let g:go_fmt_command = "gofmt"
let g:go_fmt_options = {
  \ 'gofmt': '-s',
  \ }

" godef
"" Use gopls with vim-lsp
let g:go_def_mapping_enabled = 0
let g:go_def_mode = 'guru'
let g:go_info_mode = 'gocode'

" mapping functions
nnoremap <silent> <Leader>lt :GoTest<CR>
nnoremap <silent> <Leader>lc :GoTestCompile<CR>
nnoremap <silent> <Leader>lf :GoImports<CR>
