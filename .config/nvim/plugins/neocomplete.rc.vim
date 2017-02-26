" 起動時に有効化
let g:neocomplete#enable_at_startup = 1
" 大文字が入力されるまで大文字小文字の区別を無視する
let g:neocomplete#enable_smart_case = 1
" _(アンダースコア)区切りの補完を有効化
let g:neocomplete#enable_underbar_completion = 1
let g:neocomplete#enable_camel_case_completion  =  1
" ポップアップメニューで表示される候補の数
let g:neocomplete#max_list = 20
" シンタックスをキャッシュするときの最小文字長
let g:neocomplete#sources#syntax#min_keyword_length = 3
" 補完を表示する最小文字数
let g:neocomplete#auto_completion_start_length = 2
" preview window を閉じない
let g:neocomplete#enable_auto_close_preview = 0
" AutoCmd InsertLeave * silent! pclose!

let g:neocomplete#max_keyword_width = 10000

if !exists('g:neocomplete#delimiter_patterns')
  let g:neocomplete#delimiter_patterns= {}
endif
let g:neocomplete#delimiter_patterns.ruby = ['::']

if !exists('g:neocomplete#same_filetypes')
  let g:neocomplete#same_filetypes = {}
endif
let g:neocomplete#same_filetypes.ruby = 'eruby'


if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif

let g:neocomplete#force_omni_input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
let g:neocomplete#force_omni_input_patterns.typescript = '[^. \t]\.\%(\h\w*\)\?' " Same as JavaScript
let g:neocomplete#force_omni_input_patterns.go = '[^. \t]\.\%(\h\w*\)\?'         " Same as JavaScript

let s:neco_dicts_dir = $HOME . '/dicts'
if isdirectory(s:neco_dicts_dir)
  let g:neocomplete#sources#dictionary#dictionaries = {
        \ 'ruby': s:neco_dicts_dir . '/ruby.dict',
        \ 'javascript': s:neco_dicts_dir . '/jquery.dict',
        \ 'scala' : $HOME.'/.vim/bundle/vim-scala/dict/scala.dict',
        \ 'java' : $HOME.'/.vim/dict/java.dict',
        \ 'c' : $HOME.'/.vim/dict/c.dict',
        \ 'cpp' : $HOME.'/.vim/dict/cpp.dict',
        \ 'javascript' : $HOME.'/.vim/dict/javascript.dict',
        \ 'ocaml' : $HOME.'/.vim/dict/ocaml.dict',
        \ 'perl' : $HOME.'/.vim/dict/perl.dict',
        \ 'php' : $HOME.'/.vim/dict/php.dict',
        \ 'scheme' : $HOME.'/.vim/dict/scheme.dict',
        \ 'vm' : $HOME.'/.vim/dict/vim.dict'
        \ }
endif
let g:neocomplete#data_directory = $HOME . '/.vim/cache/neocomplete'

call neocomplete#custom#source('look', 'min_pattern_length', 1)
