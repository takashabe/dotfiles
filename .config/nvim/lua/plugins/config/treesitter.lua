require'nvim-treesitter.configs'.setup {
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
  auto_install = true,

  highlight = {
    enable = true,
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
    additional_vim_regex_highlighting = false,
  },
}
