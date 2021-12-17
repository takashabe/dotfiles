command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --hidden --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" Prefix
nmap <Leader>f [fzf]
noremap [fzf] <Nop>

" fzf shortcut
nnoremap <C-p>  :Files<CR>
nnoremap [fzf]f :Files<CR>
nnoremap [fzf]b :Buffers<CR>
nnoremap [fzf]s :Rg<Space>
nnoremap [fzf]g :GFiles<CR>
nnoremap [fzf]c :GFiles?<CR>
