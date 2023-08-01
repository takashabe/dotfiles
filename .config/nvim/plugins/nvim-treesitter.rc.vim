lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- see: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  ensure_installed = {
    "c",
    "cpp",
    "cmake",
    "fish",
    "go",
    "gomod",
    "gowork",
    "graphql",
    "hcl",
    "html",
    "json",
    "lua",
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
