-- お試しプラグインを置く場所. プラグインの処遇が決まったらこのファイルから移動すること
return {
  -- 2025/01/15 align系で良さそう
  {
    'echasnovski/mini.align',
    opts = {
        mappings = {
          start = '<leader>ga',
          start_with_preview = '<leader>gA',
        },
    },
  },
  -- 2025/02/11 色々できる系のプラグイン. folke-san製品
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile      = { enabled = false },
      dashboard    = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          -- zshがちゃんと動かないのでコメントアウト
          -- {
          --   section = "terminal",
          --   cmd = "pokemon-colorscripts -r --no-title; sleep .1",
          --   random = 10,
          --   pane = 2,
          --   indent = 4,
          --   height = 30,
          -- },
        },
      },
      explorer     = { enabled = true },
      indent       = {
        enabled = true,
        animate = {
          enabled = false,
        },
      },
      input        = { enabled = true },
      picker       = {
        enabled = true,
        source = {
          todo_comments = { hidden = true }, -- https://github.com/folke/todo-comments.nvim
        },
      },
      notifier     = { enabled = true },
      quickfile    = { enabled = false },
      scope        = { enabled = false },
      scroll       = { enabled = false },
      statuscolumn = { enabled = true },
      words        = { enabled = true },
    },
    keys = {
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
      -- fuzzy finder
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<C-p>",      function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
      { "<leader>fn", function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { '<leader>f/', function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>fc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>fl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>fq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>f?", function() Snacks.picker.commands() end, desc = "Commands" },
      -- LSP
      -- glanceとどっち取るか悩み中. g* のキーマップとしてvim.lsp系は定義してあるのでコンフリクト注意
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
      { "gt", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
      { "gi", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
      -- git
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
      -- Grep/Search
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo comments" },
      -- Other
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    },
  },
  config = function()
    -- lsp_progress を通知するようにする. fidget.nvimの代替
    vim.api.nvim_create_autocmd("LspProgress", {
      ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      callback = function(ev)
        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(vim.lsp.status(), "info", {
          id = "lsp_progress",
          title = "LSP Progress",
          opts = function(notif)
            notif.icon = ev.data.params.value.kind == "end" and " "
            or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })
  end,
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
