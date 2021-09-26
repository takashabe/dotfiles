" keymap
nnoremap <Leader>as :Vista!!<CR>

" vista configurations
let g:vista_default_executive = 'vim_lsp'
let g:vista_fzf_preview = ['right:50%']
let g:vista#renderer#enable_icon = 1
let g:vista_sidebar_position = 'vertical topleft'

let g:vista_icon_indent = ["󳄀󳄂 ", "󳄁󳄂 "]
let g:vista#renderer#icons = {
  \ 'func':           "\Uff794",
  \ 'function':       "\Uff794",
  \ 'functions':      "\Uff794",
  \ 'var':            "\Uff71b",
  \ 'variable':       "\Uff71b",
  \ 'variables':      "\Uff71b",
  \ 'const':          "\Uff8ff",
  \ 'constant':       "\Uff8ff",
  \ 'method':         "\Uff6a6",
  \ 'package':        "\Ufe612",
  \ 'packages':       "\Ufe612",
  \ 'enum':           "\Uff435",
  \ 'enumerator':     "\Uff435",
  \ 'module':         "\Uff668",
  \ 'modules':        "\Uff668",
  \ 'type':           "\Ufe22b",
  \ 'typedef':        "\Ufe22b",
  \ 'types':          "\Ufe22b",
  \ 'field':          "\Uff93d",
  \ 'fields':         "\Uff93d",
  \ 'macro':          "\Uff8a3",
  \ 'macros':         "\Uff8a3",
  \ 'map':            "\Uffb44",
  \ 'class':          "\Uff9a9",
  \ 'augroup':        "\Uffb44",
  \ 'struct':         "\Uffb44",
  \ 'union':          "\Uffacd",
  \ 'member':         "\Uff02b",
  \ 'target':         "\Uff893",
  \ 'property':       "\Uffab6",
  \ 'interface':      "\Uffa52",
  \ 'namespace':      "\Uff475",
  \ 'subroutine':     "\Uff915",
  \ 'implementation': "\Uff87a",
  \ 'typeParameter':  "\Uff278",
  \ 'default':        "\Uff29c"
  \ }
