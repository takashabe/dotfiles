let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_float_cursor = 1
let g:lsp_text_edit_enabled = 0

" debug
" let g:lsp_log_verbose = 1
" let g:lsp_log_file = expand('~/vim-lsp.log')
" let g:asyncomplete_log_file = expand('~/asyncomplete.log')

function! s:on_lsp_buffer_enabled() abort
  " omnifunc
  setlocal omnifunc=lsp#complete

  " map
  nnoremap <buffer><silent> gd :<C-u>LspDefinition<CR>
  nnoremap <buffer><silent> gD :<C-u>LspReferences<CR>
  nnoremap <buffer><silent> gs :<C-u>LspDocumentSymbol<CR>
  nnoremap <buffer><silent> gS :<C-u>LspWorkspaceSymbol<CR>
  nnoremap <buffer><silent> gf :<C-u>LspDocumentFormatSync<CR>
  nnoremap <buffer><silent> gh :<C-u>LspHover<CR>
  nnoremap <buffer><silent> gi :<C-u>LspImplementation<CR>
  nnoremap <buffer><silent> gr :<C-u>LspRename<CR>
  nnoremap <buffer><silent> ga :<C-u>LspDocumentDiagnostics<CR>
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" vim-lsp-settings
let g:lsp_settings_filetype_go = ['gopls', 'golangci-lint-langserver']
let g:lsp_settings_filetype_terraform = ['terraform-ls']

let g:lsp_settings = {}
let g:lsp_settings['golangci-lint-langserver'] = {
  \  'initialization_options': {
  \    'command': ['golangci-lint', 'run',
  \      '--disable-all',
  \      '--enable', 'govet',
  \      '--enable', 'golint',
  \      '--exclude-use-default=false',
  \      '--out-format', 'json',
  \      '--max-same-issues', '0',
  \      '--max-issues-per-linter', '0'
  \    ],
  \  },
  \}
