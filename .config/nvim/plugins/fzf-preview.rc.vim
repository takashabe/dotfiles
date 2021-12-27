" true color for nvim
if has('nvim')
  augroup fzf_preview
    autocmd!
    autocmd User fzf_preview#rpc#initialized call s:fzf_preview_settings() " fzf_preview#remote#initialized or fzf_preview#coc#initialized
  augroup END

  function! s:fzf_preview_settings() abort
    let g:fzf_preview_command = 'COLORTERM=truecolor ' . g:fzf_preview_command
    let g:fzf_preview_grep_preview_cmd = 'COLORTERM=truecolor ' . g:fzf_preview_grep_preview_cmd
  endfunction
end

" Prefix
nmap <Leader>f [fzf]
noremap [fzf] <Nop>

" fzf shortcut
nnoremap <C-p>  :<C-u>FzfPreviewDirectoryFilesRpc<CR>
nnoremap [fzf]f :<C-u>FzfPreviewDirectoryFilesRpc<CR>
nnoremap [fzf]b :<C-u>FzfPreviewAllBuffersRpc<CR>
nnoremap [fzf]s :<C-u>FzfPreviewProjectGrepRpc<Space>
