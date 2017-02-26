let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
" 'go fmt'を'goimports'に置き換える
let g:go_fmt_command = "goimports"
let g:go_file_type = "quickfix"
" alias command
command! Gt :GoTest
command! Gr :GoRename
