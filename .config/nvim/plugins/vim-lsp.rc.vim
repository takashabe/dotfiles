if executable('bingo')
  augroup LspGo
    au!
    au User lsp_setup call lsp#register_server({
        \ 'name': 'bingo',
        \ 'cmd': {server_info->['bingo', '--format-style', 'goimports', '--diagnostics-style', 'instant', '--cache-style', 'global']},
        \ 'whitelist': ['go'],
        \ })
    " omnifunc
    autocmd FileType go setlocal omnifunc=lsp#complete
    " map
    au FileType go nnoremap <buffer><silent> gd :<C-u>LspDefinition<CR>
    au FileType go nnoremap <buffer><silent> gD :<C-u>LspReferences<CR>
    au FileType go nnoremap <buffer><silent> gs :<C-u>LspDocumentSymbol<CR>
    au FileType go nnoremap <buffer><silent> gS :<C-u>LspWorkspaceSymbol<CR>
    au FileType go nnoremap <buffer><silent> gQ :<C-u>LspDocumentFormat<CR>
    au FileType go vnoremap <buffer><silent> gQ :LspDocumentRangeFormat<CR>
    au FileType go nnoremap <buffer><silent> K :<C-u>LspHover<CR>
    au FileType go nnoremap <buffer><silent> <F1> :<C-u>LspImplementation<CR>
    au FileType go nnoremap <buffer><silent> <F2> :<C-u>LspRename<CR>
    " auto fmt
    " TODO: 意図通りにformatされないことが多かったので直接goimportsを呼ぶよう
    " にしている(options.rc.vim)
    " autocmd BufWritePre *.go :LspDocumentFormat
  augroup end
endif
