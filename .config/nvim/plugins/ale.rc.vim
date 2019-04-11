" ファイル保存時のみ lint
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0

" quickfix にエラー内容を出す
let g:ale_open_list = 1
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

" Linter list
let g:ale_linters = {
  \'go': ['golangci-lint', 'golint'],
\}

let g:ale_go_golangci_lint_options = '--disable-all
  \ -E govet
  \ -E errcheck
  \ -E staticcheck
  \ -E gosimple
  \ -E gounused
  \'

" Format code for me on save
let g:ale_fix_on_save = 1

" Formatter list
let g:ale_fixers = {'go': ['goimports']}
