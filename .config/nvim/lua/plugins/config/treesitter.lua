require("nvim-treesitter").install({
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
})

-- vim.api.nvim_create_autocmd("FileType", {
--   callback = function(args)
--     -- FileType から Tree-sitter 用の言語名を取得
--     local lang = vim.treesitter.language.get_lang(args.match)
--     if not lang then
--       return
--     end
--
--     -- その言語のパーサーが「実際に利用可能か」を確認
--     -- pcall を使うことで、パーサーがない場合にエラーで止まるのを防ぐ
--     local has_parser = pcall(vim.treesitter.get_parser, args.buf, lang)
--     if has_parser then
--       vim.treesitter.start(args.buf, lang)
--     end
--   end,
-- })
--
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_auto_start", { clear = true }),
  callback = function(args)
    -- 1. FileTypeから言語名を解決
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end

    -- 2. pcall で安全にパーサー取得を試みる
    -- 0.11: パーサーが無い場合 error を throw する
    -- 0.12: パーサーが無い場合 nil を返す（pcall + nil チェックで両対応）
    local ok, parser = pcall(vim.treesitter.get_parser, args.buf, lang)

    if ok and parser then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})
