" Disable auto lint
let g:ale_lint_on_save = 0
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0

" Format code for me on save
let g:ale_fix_on_save = 0

" Formatter list
let g:ale_fixers = {'go': ['goimports']}

nnoremap <silent> <Leader>af :ALEFix<CR>
