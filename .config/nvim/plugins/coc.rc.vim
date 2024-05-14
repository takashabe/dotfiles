let g:coc_node_path = '/Users/takashabe/.volta/bin/node'
let g:coc_global_extensions = [
      \'coc-lists',
      \'coc-fzf-preview',
      \'coc-snippets',
      \'coc-diagnostic',
      \'coc-dictionary',
      \'coc-go',
      \'coc-lua',
      \'coc-tsserver',
      \'coc-vetur',
      \'coc-pyright',
      \'coc-prettier',
      \'coc-yaml',
      \'coc-json',
      \'coc-markdownlint',
      \'coc-sql',
      \'coc-rust-analyzer',
\]

" ##############################
" mapping
" ##############################
" completion. https://github.com/neoclide/coc.nvim#example-vim-configuration
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <C-Space> coc#refresh()

nmap gs :<C-u>call <SID>show_documentation()<CR>
nmap gd <Plug>(coc-definition)
nmap gr <Plug>(coc-rename)
nmap ga <Plug>(coc-codeaction-selected)iw
nmap gi <Plug>(coc-implementation)
nmap }  <Plug>(coc-diagnostic-next)
nmap {  <Plug>(coc-diagnostic-prev)
nnoremap <silent> ge  :<C-u>CocCommand fzf-preview.CocCurrentDiagnostics<CR>
nnoremap <silent> gD  :<C-u>CocCommand fzf-preview.CocReferences<CR>
nnoremap <silent> go  :<C-u>CocCommand fzf-preview.CocOutline --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>

function! s:show_documentation() abort
  if index(['vim','help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  elseif coc#rpc#ready()
    call CocActionAsync('doHover')
  endif
endfunction

" ##############################
" Go
" ##############################

augroup coc_go
  autocmd!
  autocmd BufWritePre *.go :silent call CocAction('runCommand', 'editor.action.organizeImport')
augroup END

" ##############################
" TypeScript
" ##############################
function! s:coc_typescript_settings() abort
  nnoremap <silent> <buffer> [dev]f :<C-u>CocCommand eslint.executeAutofix<CR>:CocCommand prettier.formatFile<CR>
endfunction

augroup coc_ts
  autocmd!
  autocmd FileType typescript,typescriptreact call <SID>coc_typescript_settings()
augroup END
