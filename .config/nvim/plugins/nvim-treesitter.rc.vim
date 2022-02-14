lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  sync_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
  },
}
EOF
