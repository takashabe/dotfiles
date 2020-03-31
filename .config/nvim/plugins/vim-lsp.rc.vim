let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_signs_enabled = 1
let g:lsp_textprop_enabled = 0
let g:lsp_virtual_text_enabled = 0
let g:lsp_highlight_references_enabled = 0

" https://github.com/prabirshrestha/asyncomplete.vim/issues/156
let g:lsp_text_edit_enabled = 0

" debug
" let g:lsp_log_verbose = 1
" let g:lsp_log_file = expand('~/vim-lsp.log')
" let g:asyncomplete_log_file = expand('~/asyncomplete.log')

if executable('gopls')
  augroup LspGo
    au!
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls']},
        \ 'whitelist': ['go'],
        \ })
    " omnifunc
    autocmd FileType go setlocal omnifunc=lsp#complete

    " autocmd
    autocmd FileType go autocmd BufWritePre <buffer> silent LspDocumentFormatSync

    " map
    au FileType go nnoremap <buffer><silent> gd :<C-u>LspDefinition<CR>
    au FileType go nnoremap <buffer><silent> gD :<C-u>LspReferences<CR>
    au FileType go nnoremap <buffer><silent> gs :<C-u>LspDocumentSymbol<CR>
    au FileType go nnoremap <buffer><silent> gS :<C-u>LspWorkspaceSymbol<CR>
    au FileType go nnoremap <buffer><silent> gf :<C-u>LspDocumentFormatSync<CR>
    au FileType go nnoremap <buffer><silent> gh :<C-u>LspHover<CR>
    au FileType go nnoremap <buffer><silent> gi :<C-u>LspImplementation<CR>
    au FileType go nnoremap <buffer><silent> gr :<C-u>LspRename<CR>
    au FileType go nnoremap <buffer><silent> ga :<C-u>LspDocumentDiagnostics<CR>
  augroup end
endif

if executable('pyls')
  augroup LspPython
    au!
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
    " omnifunc
    autocmd FileType go setlocal omnifunc=lsp#complete

    " autocmd
    autocmd FileType go autocmd BufWritePre <buffer> silent LspDocumentFormatSync

    " map
    au FileType python nnoremap <buffer><silent> gd :<C-u>LspDefinition<CR>
    au FileType python nnoremap <buffer><silent> gD :<C-u>LspReferences<CR>
    au FileType python nnoremap <buffer><silent> gs :<C-u>LspDocumentSymbol<CR>
    au FileType python nnoremap <buffer><silent> gS :<C-u>LspWorkspaceSymbol<CR>
    au FileType python nnoremap <buffer><silent> gf :<C-u>LspDocumentFormatSync<CR>
    au FileType python nnoremap <buffer><silent> gh :<C-u>LspHover<CR>
    au FileType python nnoremap <buffer><silent> gi :<C-u>LspImplementation<CR>
    au FileType python nnoremap <buffer><silent> gr :<C-u>LspRename<CR>
    au FileType python nnoremap <buffer><silent> ga :<C-u>LspDocumentDiagnostics<CR>
  augroup end
endif
