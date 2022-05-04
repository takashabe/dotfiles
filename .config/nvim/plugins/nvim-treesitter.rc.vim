lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- see: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  ensure_installed = {
    "cmake",
    "dockerfile",
    "fish",
    "go",
    "hcl",
    "html",
    "json",
    "lua",
    "make",
    "python",
    "rust",
    "toml",
    "typescript",
    "vim",
    "vue",
    "yaml",
  },
  sync_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
  },
}
EOF
