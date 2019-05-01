" Highlit
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_string_spellcheck = 1
let g:go_highlight_format_strings = 1

" Formatter
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
let g:go_fmt_options = {
  \ 'gofmt': '-s',
  \ 'goimports': '',
  \ }

" godef
"" Use gopls with vim-lsp
let g:go_def_mapping_enabled = 0

" mapping functions
" TODO
