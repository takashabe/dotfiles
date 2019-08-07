let g:lsp_auto_enable = 1

let g:lsp_diagnostics_enabled = 1
let g:lsp_signs_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_highlight_references_enabled = 0

if executable('gopls')
  augroup LspGo
    au!
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
        \ 'whitelist': ['go'],
        \ })
    " omnifunc
    autocmd FileType go setlocal omnifunc=lsp#complete

    " format
    autocmd FileType go autocmd BufWritePre <buffer> LspDocumentFormatSync

    " map
    au FileType go nnoremap <buffer><silent> gd :<C-u>LspDefinition<CR>
    au FileType go nnoremap <buffer><silent> gD :<C-u>LspReferences<CR>
    au FileType go nnoremap <buffer><silent> gs :<C-u>LspDocumentSymbol<CR>
    au FileType go nnoremap <buffer><silent> gS :<C-u>LspWorkspaceSymbol<CR>
    au FileType go nnoremap <buffer><silent> gf :<C-u>LspDocumentFormatSync<CR>
    au FileType go nnoremap <buffer><silent> gh :<C-u>LspHover<CR>
    au FileType go nnoremap <buffer><silent> gi :<C-u>LspImplementation<CR>
    au FileType go nnoremap <buffer><silent> gr :<C-u>LspRename<CR>
  augroup end
endif
