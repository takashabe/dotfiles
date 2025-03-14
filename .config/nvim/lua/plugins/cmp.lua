-- ghost_text の色を設定
local colors = require("catppuccin.palettes").get_palette("frappe")
vim.api.nvim_set_hl(0, 'BlinkCmpGhostText', { fg = colors.overlay0, italic = true })

return {
  {
    'saghen/blink.cmp',
    version = '*', -- リリースタグを使用して事前ビルドされたバイナリをダウンロード
    dependencies = {
      'rafamadriz/friendly-snippets', -- スニペット用
      'giuxtaposition/blink-cmp-copilot',
    },
    opts = {
      keymap = { preset = 'default' },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
        kind_icons = {
          Text = "󰉿",
          Method = "󰆧",
          Function = "󰊕",
          Constructor = "",
          Field = "󰜢",
          Variable = "󰀫",
          Class = "󰠱",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "󰑭",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Snippet = "",
          Color = "󰏘",
          File = "󰈙",
          Reference = "󰈇",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "󰙅",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "",
          Copilot = "",
        },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = { enabled = true },
        menu = {
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind", gap = 1 }
            },
          },
        },
      },
      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
      sources = {
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
        -- cmdlineで短い文字数で補完が出ると煩わしい
        min_keyword_length = function(ctx)
          -- :wq, :qa -> menu doesn't popup
          -- :Lazy, :wqa -> menu popup
          if ctx.mode == "cmdline" and ctx.line:find("^%l+$") ~= nil then
            return 3
          end
          return 0
        end,
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
      },
      cmdline = {
        enabled = true,
        keymap = {
          ['<Tab>'] = { 'show', 'accept' },
        },
        completion = {
          menu = {
            auto_show = true,
          },
        }
      },
    },
    opts_extend = { "sources.default" } -- 設定を再定義せずに拡張可能
  }
}

