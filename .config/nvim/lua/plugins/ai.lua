return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        mux = {
          backend = "tmux",
          enabled = false,
        },
        win = {
          keys = {
            nav_left = false,
            nav_down = false,
            nav_up = false,
            nav_right = false,
          },
        },
        -- sidekick が :terminal 経路で claude code を起動すると、claude の tmux passthrough シーケンスが Neovim 側で文字列として漏れる。$TMUX を 空にして非 tmux 経路を使わせることで抑制する。
        -- 副作用: tmux 経由の OSC 52 クリップボード連携などは効かなくなる。
        tools = {
          claude = {
            env = {
              TMUX = false,
            },
          },
        },
      },
      nes = {
        enabled = false,
      },
    },
    -- stylua: ignore
    keys = {
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle({ focus = true }) end,
        mode = { "n", "v" },
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>aS",
        function() require("sidekick.cli").select() end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = "Select CLI",
      },
      {
        "<leader>at",
        (function()
          local function is_file_buf(b)
            return vim.bo[b].buftype == "" and vim.fn.filereadable(vim.api.nvim_buf_get_name(b)) == 1
          end

          local function send_position(win)
            local buf = vim.api.nvim_win_get_buf(win)
            local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":~:.")
            local row, col = unpack(vim.api.nvim_win_get_cursor(win))
            local ref = ("@%s :L%d:C%d"):format(name, row, col + 1)
            require("sidekick.cli").send({ msg = ref, this = false })
          end

          return function()
            local buf = vim.api.nvim_get_current_buf()
            if is_file_buf(buf) then
              send_position(vim.api.nvim_get_current_win())
              return
            end
            -- 非ファイルバッファ: タブ内からファイルバッファを探す
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              if is_file_buf(vim.api.nvim_win_get_buf(win)) then
                send_position(win)
                return
              end
            end
            -- フォールバック: ビジュアル選択なら送れる
            require("sidekick.cli").send({ msg = "{this}" })
          end
        end)(),
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ selection = true }) end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      {
        "<C-.>",
        function() require("sidekick.cli").focus() end,
        mode = { "n", "x", "i", "t" },
        desc = "Sidekick Switch Focus",
      },
      -- -- Example of a keybinding to open Claude directly
      -- {
      --   "<leader>ac",
      --   function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
      --   desc = "Sidekick Toggle Claude",
      -- },
      -- {
      --   "<leader>aC",
      --   function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end,
      --   desc = "Sidekick Toggle Codex",
      -- },
    },
  },
}
