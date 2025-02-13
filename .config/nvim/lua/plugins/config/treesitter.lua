require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "c",
    "cpp",
    "cmake",
    "diff",
    "fish",
    "go",
    "gomod",
    "gowork",
    "graphql",
    "hcl", -- includes terraform
    "html",
    "json",
    "lua",
    "python",
    "regex",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vue",
    "yaml",
  },

  sync_install = true,
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
