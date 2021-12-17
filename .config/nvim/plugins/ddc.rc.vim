if has('nvim')
  call ddc#custom#patch_global('completionMenu', 'pum.vim')
  call ddc#custom#patch_global('sources', [
   \ 'vim-lsp',
   \ 'omni',
   \ 'around',
   \ ])
  call ddc#custom#patch_global('sourceOptions', {
   \ '_': {
   \   'matchers': ['matcher_head'],
   \   'sorters': ['sorter_rank'],
   \   'converters': ['converter_remove_overlap'],
   \ },
   \ 'around': {'mark': 'Around'},
   \ 'vim-lsp': {
   \   'mark': 'LSP',
   \   'matchers': ['matcher_head'],
   \   'forceCompletionPattern': '\.|:|->|"\w+/*'
   \ },
   \ 'omni': {
   \   'mark': 'o',
   \ }})
  call ddc#enable()

  inoremap <Tab> <Cmd>call pum#map#insert_relative(+1)<CR>
  inoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
end
