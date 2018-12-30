" Util function
fun! FzfOmniFiles()
  let is_git = system('git status')
  if v:shell_error
    :Files
  else
    :GitFiles
  endif
endfun

" Prefix
nmap <Leader>f [fzf]
noremap [fzf] <Nop>

" fzf shortcut
nnoremap [fzf]b :Buffers<CR>
nnoremap [fzf]g :Rg<Space>
nnoremap [fzf]f :call FzfOmniFiles()<CR>
