" pycなどのファイルを無視(隠しファイル扱い)する
let g:vimfiler_ignore_pattern='\(^\.\|\~$\|\.pyc$\|\.[oad]$\)'
" デフォルトファイラにする
let g:vimfiler_as_default_explorer=1

" Prefix
nnoremap [vimfiler] <Nop>
nmap <Leader>v [vimfiler]
" カレントディレクトリを開く
nnoremap <silent> [vimfiler]c :VimFilerCurrentDir<CR>
inoremap <silent> [vimfiler]c <ESC>:VimFilerCurrentDir<CR>
" カレントバッファディレクトリを開く
nnoremap <silent> [vimfiler]b :VimFilerBufferDir<CR>
inoremap <silent> [vimfiler]b <ESC>:VimFilerBufferDir<CR>
" プロジェクトホームを開く
nnoremap <silent> [vimfiler]h :VimFiler -project<CR>
inoremap <silent> [vimfiler]h <ESC>:VimFiler -project<CR>
