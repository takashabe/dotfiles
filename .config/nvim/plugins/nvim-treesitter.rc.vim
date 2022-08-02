lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- see: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  ensure_installed = {
    "dockerfile",
    "fish",
    "go",
    "gomod",
    "gowork",
    "graphql",
    "hcl",
    "html",
    "json",
    "lua",
    "make",
    "python",
    "rust",
    "toml",
    "tsx",
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
