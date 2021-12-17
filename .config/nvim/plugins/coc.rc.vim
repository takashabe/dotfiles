let g:coc_global_extensions = ['coc-git', 'coc-lists', 'coc-fzf-preview']

" mappings
inoremap <buffer><silent><expr> <C-Space> coc#refresh()
nmap <buffer><silent> gs :<C-u>call <SID>show_documentation()<CR>
nmap <buffer><silent> gr <Plug>(coc-rename)
nmap <buffer><silent> ga <Plug>(coc-codeaction-selected)iw
nmap <buffer><silent> gd <Plug>(coc-definition)
nmap <buffer><silent> gD <Plug>(coc-references)
nmap <buffer><silent> gi <Plug>(coc-implementation)
nmap <buffer><silent> }  <Plug>(coc-diagnostic-next)
nmap <buffer><silent> {  <Plug>(coc-diagnostic-prev)

function! s:show_documentation() abort
  if index(['vim','help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  elseif coc#rpc#ready()
    call CocActionAsync('doHover')
  endif
endfunction

" ##############################
" typescript
" ##############################
function! s:coc_typescript_settings() abort
  nnoremap <silent> <buffer> [dev]f :<C-u>CocCommand eslint.executeAutofix<CR>:CocCommand prettier.formatFile<CR>
endfunction

augroup coc_ts
  autocmd!
  autocmd FileType typescript,typescriptreact call <SID>coc_typescript_settings()
augroup END

" ##############################
" coc-fzf-preview
" ##############################
" NOTE: depends fzf.vim
nnoremap <silent> [fzf]e  :<C-u>CocCommand fzf-preview.CocCurrentDiagnostics<CR>
nnoremap <silent> [fzf]d  :<C-u>CocCommand fzf-preview.CocDefinition<CR>
nnoremap <silent> [fzf]D  :<C-u>CocCommand fzf-preview.CocReferences<CR>
