" Highlit
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_string_spellcheck = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_fields = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1

" Formatter
let g:go_fmt_autosave = 1
let g:go_fmt_command = "gofmt"
let g:go_fmt_options = {
  \ 'gofmt': '-s',
  \ }

" godef
"" Use gopls with vim-lsp
let g:go_def_mapping_enabled = 0
let g:go_info_mode = 'gocode'
let g:go_def_mode = 'guru'

" mapping functions
nnoremap <silent> <Leader>lt :GoTest<CR>
nnoremap <silent> <Leader>lc :GoTestCompile<CR>
nnoremap <silent> <Leader>lf :GoImports<CR>
