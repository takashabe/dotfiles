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

" grep
" grep検索
nnoremap <silent> ,g<space>  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
" カーソル位置の単語をgrep検索
nnoremap <silent> ,gc :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
" grep検索結果の再呼出
nnoremap <silent> ,gr  :<C-u>UniteResume search-buffer<CR>
" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif
