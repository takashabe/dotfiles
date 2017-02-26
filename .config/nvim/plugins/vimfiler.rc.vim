" pycなどのファイルを無視(隠しファイル扱い)する
let g:vimfiler_ignore_pattern='\(^\.\|\~$\|\.pyc$\|\.[oad]$\)'
" デフォルトファイラにする
let g:vimfiler_as_default_explorer=1
" カレントディレクトリを開く
nnoremap <silent> vc :VimFilerCurrentDir<CR>
inoremap <silent> vc <ESC>:VimFilerCurrentDir<CR>
" プロジェクトホームを開く
nnoremap <silent> vh :VimFiler -project<CR>
inoremap <silent> vh <ESC>:VimFiler -project<CR>
