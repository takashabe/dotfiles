let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"
let g:go_file_type = "quickfix"
let g:go_def_mode = "guru"

" lang remap
nnoremap <silent> <Leader>lt :GoTest<CR>
nnoremap <silent> <Leader>lc :GoTestCompile<CR>
nnoremap <silent> <Leader>lr :GoRename<CR>

" neomake
let g:neomake_go_enabled_makers = ['golint', 'govet']
