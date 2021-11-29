let g:lsp_document_highlight_enabled = 1
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_float_cursor = 1
let g:lsp_text_edit_enabled = 0
let g:lsp_semantic_enabled = 1
let g:lsp_work_done_progress_enabled = 1

highlight lspReference ctermfg=red guifg=red ctermbg=green guibg=green

" debug
" let g:lsp_log_verbose = 1
" let g:lsp_log_file = expand('~/vim-lsp.log')
" let g:asyncomplete_log_file = expand('~/asyncomplete.log')

function! s:on_lsp_buffer_enabled() abort
  " omnifunc
  setlocal omnifunc=lsp#complete

  " map
  nnoremap <buffer><silent> ga :<C-u>LspCodeAction<CR>
  nnoremap <buffer><silent> gd :<C-u>LspDefinition<CR>
  nnoremap <buffer><silent> gD :<C-u>LspReferences<CR>
  nnoremap <buffer><silent> gs :<C-u>LspDocumentSymbol<CR>
  nnoremap <buffer><silent> gS :<C-u>LspWorkspaceSymbol<CR>
  nnoremap <buffer><silent> gf :<C-u>LspDocumentFormatSync<CR>
  nnoremap <buffer><silent> gh :<C-u>LspHover<CR>
  nnoremap <buffer><silent> gi :<C-u>LspImplementation<CR>
  nnoremap <buffer><silent> gr :<C-u>LspRename<CR>
  nnoremap <buffer><silent> ge :<C-u>LspDocumentDiagnostics<CR>
  nnoremap } :<C-u>LspNextDiagnostic<CR>
  nnoremap { :<C-u>LspPreviousDiagnostic<CR>
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" vim-lsp-settings
" using global settings.json (XDG_DATA_HOME/vim-lsp-settings/settings.json)
let g:lsp_settings_filetype_go = ['gopls', 'golangci-lint-langserver']
let g:lsp_settings_filetype_terraform = ['terraform-ls']
let g:lsp_settings_filetype_sql = ['sqls']
