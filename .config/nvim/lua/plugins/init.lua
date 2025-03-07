return {
  -- llm
  -- { "github/copilot.vim", },
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      -- { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken",                          -- Only on MacOS or Linux
    opts = {
      debug = true,
      proxy = nil,
      allow_insecure = false,
      model = 'claude-3.7-sonnet',
      temperature = 0.1,
      prompts = {
        Explain = '/COPILOT_EXPLAIN 選択したコードの説明を段落をつけて書いてください。',
        Fix = '/COPILOT_FIX このコードには問題があります。バグを修正したコードに書き換えてください。',
        Optimize = '/COPILOT_OPTIMIZE 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。',
        Docs =
        '/COPILOT_DOCS 選択したコードのドキュメントを書いてください。ドキュメントをコメントとして追加した元のコードを含むコードブロックで回答してください。使用するプログラミング言語に最も適したドキュメントスタイルを使用してください（例：JavaScriptのJSDoc、Pythonのdocstringsなど）',
        Tests = '/COPILOT_TESTS 選択したコードの詳細な単体テスト関数を書いてください。',
        FixDiagnostic = '/COPILOT_FIXDIAGNOSTIC ファイル内の次のような診断上の問題を解決してください：',
        Commit = '/COPILOT_COMMIT この変更をコミットしてください。Conventional Commitメッセージを使用してください。',
      },
      window = {
        layout = 'vertical',
        width = 0.3,
        height = 0.3,
        relative = 'editor',
        border = 'single',
        row = 0,
        col = 0,
        title = 'Copilot Chat',
        footer = nil,
        zindex = 1,
      },
    },
    keys = {
      {
        -- CopilotChat Quick
        "<leader>ccq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      {
        -- CopilotChat Prompt actions
        "<leader>ccp",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
      },
    },
  },

  -- cmp
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
    config = function()
      -- nvim-cmp setup
      local lspkind = require 'lspkind'
      lspkind.init {}

      local cmp = require 'cmp'
      cmp.setup {
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'copilot' },
          { name = 'vsnip' }, -- For vsnip users.
          { name = 'buffer' },
        }),
        formatting = ({
          format = lspkind.cmp_format({
            maxwidth = 80,
            mode = 'symbol_text',
            symbol_map = {
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
          }),
        }),
      }

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })

      cmp.setup.filetype('copilot-chat', {
        sources = {
          { name = 'copilot' },
          { name = 'buffer' },
          { name = 'snippets' },
        },
      })
    end,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-vsnip', -- For vsnip users.
      'hrsh7th/vim-vsnip', -- For vsnip users.
      'zbirenbaum/copilot-cmp',
      'onsails/lspkind-nvim',
    }
  },

  -- lsp
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require('plugins.config.lsp')
    end,
  },
  {
    'nvimtools/none-ls.nvim', -- none-ls is an active community fork of null-ls
    opts = function(_, opts)
      local nls = require('null-ls')
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.code_actions.gomodifytags,
        nls.builtins.code_actions.impl,
      })
      return opts
    end,
  },

  -- telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'LukasPietzschmann/telescope-tabs',
    },
    keys = {
      -- { '<C-p>',      function() require('telescope.builtin').find_files() end,      mode = 'n' }, -- vscodeライクにCmd-pにしたい
      -- { '<leader>ff', function() require('telescope.builtin').find_files() end,      mode = 'n' },
      -- { '<leader>fg', function() require('telescope.builtin').live_grep() end,       mode = 'n' },
      -- { '<leader>fb', function() require('telescope.builtin').buffers() end,         mode = 'n' },
      -- { '<leader>fh', function() require('telescope.builtin').help_tags() end,       mode = 'n' },
      -- { '<leader>fd', function() require('telescope.builtin').diagnostics() end,     mode = 'n' },
      -- { '<leader>fk', function() require('telescope.builtin').keymaps() end,         mode = 'n' },
      -- { '<leader>f?', function() require('telescope.builtin').commands() end,        mode = 'n' },
      -- { '<leader>ft', function() require('telescope-tabs').list_tabs() end,          mode = 'n' },
    },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--follow",        -- Follow symbolic links
          "--hidden",        -- Search for hidden files
          "--no-heading",    -- Don't group matches by each file
          "--with-filename", -- Print the file path with the matched lines
          "--line-number",   -- Show line numbers
          "--column",        -- Show column numbers
          "--smart-case",    -- Smart case search
          "--glob=!.git/*",
          "--glob=!node_modules/*",
          "--glob=!vendor/*",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = {
            "rg",
            "--files",
            "--follow",        -- Follow symbolic links
            "--hidden",        -- Search for hidden files
            "--no-heading",    -- Don't group matches by each file
            "--with-filename", -- Print the file path with the matched lines
            "--line-number",   -- Show line numbers
            "--column",        -- Show column numbers
            "--smart-case",    -- Smart case search
            "--glob=!.git/*",
            "--glob=!node_modules/*",
            "--glob=!vendor/*",
          },
        },
      },
      function()
        require('telescope').load_extension 'telescope-tabs'
      end,
    },
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('plugins.config.treesitter')
    end,
  },
  { 'nvim-treesitter/nvim-treesitter-context', },

  -- Editor
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",
    },
    config = function()
      require('plugins.config.neotree')
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {
        view = {
          side = "left",
          -- min, maxを指定することで自動的にリサイズされる
          width = {
            min = 30,
            max = 80,
          },
        },
      }
    end,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
      })
    end
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      defaults = {},
      spec = {
        {
          mode = { "n", "v" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
          -- better descriptions
          { "gx", desc = "Open with system app" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n" },      function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n" },      function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",          function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },      function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
  {
    "mhartington/formatter.nvim",
    config = function()
      require("formatter").setup({
        filetype = {
          json = { require("formatter.filetypes.json").biome },
          javascript = { require("formatter.filetypes.javascript").biome },
          javascriptreact = { require("formatter.filetypes.javascriptreact").biome },
          typescript = { require("formatter.filetypes.typescript").biome },
          typescriptreact = { require("formatter.filetypes.typescriptreact").biome },
        },
      })
    end,
  },

  -- UI
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {
          {'filename', path = 1},
        },
        lualine_x = {'selectioncount', 'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
    },
  },
  { 'RRethy/vim-illuminate' },

  -- colorscheme
  { "catppuccin/nvim",                         name = "catppuccin", priority = 1000 },
  { "folke/tokyonight.nvim",                   lazy = false,        priority = 1000 },

  -- git
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    "pwntester/octo.nvim",
    opts = {
      enable_builtin = true,
      default_to_projects_v2 = true,
      picker = "telescope",
    },
  },

  -- lang
  { 'nanotee/sqls.nvim', },


  -- misc
  {
    "uga-rosa/translate.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>tr", "<Cmd>Translate JA<CR>", mode = { "n" }, desc = "Translate" },
    },
    opts = {
      default = {
        command = "google",
        output = "split",
      },
      preset = {
        output = {
          split = {
            border = "rounded",
            height = 15,
          },
        },
      },
    },
  },
  {
    "folke/lazydev.nvim",
    dependencies = {
      { "Bilal2453/luvit-meta", lazy = true },
      { "hrsh7th/nvim-cmp" },
    },
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "keaising/im-select.nvim",
    config = function()
      require("im_select").setup({})
    end,
  },
}
