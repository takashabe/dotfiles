-- sidekick 本体に最大化機能がないため自前で用意する
-- float と split で退避値の型（win_config / 整数）が異なるため sk_restore は any
---@class sidekick.cli.Terminal.maximizable : sidekick.cli.Terminal
---@field sk_restore? any
---@param t sidekick.cli.Terminal.maximizable
local function maximize(t)
  local win = t.win
  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end
  if t:is_float() then
    if t.sk_restore then
      vim.api.nvim_win_set_config(win, t.sk_restore)
      t.sk_restore = nil
    else
      t.sk_restore = vim.api.nvim_win_get_config(win)
      vim.api.nvim_win_set_config(win, {
        relative = "editor",
        row = 0,
        col = 0,
        width = vim.o.columns - 2,
        height = vim.o.lines - 2,
      })
    end
    return
  end
  -- left/right split は幅、top/bottom は高さが winfix される軸
  local vertical = t.opts.layout == "top" or t.opts.layout == "bottom"
  local get = vertical and vim.api.nvim_win_get_height or vim.api.nvim_win_get_width
  local set = vertical and vim.api.nvim_win_set_height or vim.api.nvim_win_set_width
  if t.sk_restore then
    set(win, t.sk_restore)
    t.sk_restore = nil
  else
    t.sk_restore = get(win)
    set(win, vertical and vim.o.lines or vim.o.columns)
  end
end

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
            maximize = {
              "<c-,>",
              maximize,
              mode = "nt",
              desc = "Sidekick: Toggle maximize",
            },
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
