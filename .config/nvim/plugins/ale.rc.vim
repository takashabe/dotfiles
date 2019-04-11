"ファイル保存時のみ lint
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0

" quickfix にエラー内容を出す
let g:ale_open_list = 1
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

let g:ale_linters = {'go': ['golangci-lint']}
