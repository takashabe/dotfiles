let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_signs_enabled = 1
let g:lsp_textprop_enabled = 0
let g:lsp_virtual_text_enabled = 0
let g:lsp_highlight_references_enabled = 0

" experimental
" https://github.com/prabirshrestha/asyncomplete.vim/issues/156
let g:lsp_text_edit_enabled = 1

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
