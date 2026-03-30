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

    -- 2. ユーザー提案の最適解: get_parser の戻り値で安全にハンドリング
    -- パーサーが存在しない場合、内部の npcall によって nil とエラー文字列が返る（クラッシュしない）
    local parser, _ = vim.treesitter.get_parser(args.buf, lang)

    -- 3. パーサーが正常に取得（作成）できた場合のみ start を実行
    -- start 内部の assert を確実に通過できる
    if parser then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})
