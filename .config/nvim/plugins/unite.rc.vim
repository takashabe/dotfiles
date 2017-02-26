" 挿入モードで開始する
let g:unite_enable_start_insert=1
" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
" keymap
" 全部乗せ
nnoremap <silent> fa  :<C-u>UniteWithCurrentDir -no-split -no-resize -start-insert -buffer-name=files buffer file_mru bookmark file<CR>
" ファイル一覧
nnoremap <silent> ff  :<C-u>Unite -no-split -no-resize -start-insert -buffer-name=files file<CR>
" バッファ一覧
nnoremap <silent> fb  :<C-u>Unite -no-split -no-resize -start-insert buffer<CR>
" 常用セット
nnoremap <silent> fu  :<C-u>Unite -no-split -no-resize -start-insert buffer file_mru<CR>
" 最近使用したファイル一覧
nnoremap <silent> fm  :<C-u>Unite -no-split -no-resize -start-insert file_mru<CR>
" 現在のバッファのカレントディレクトリからファイル一覧
nnoremap <silent> fd  :<C-u>UniteWithBufferDir -no-split -no-resize -start-insert file<CR>
