return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "zbirenbaum/copilot.lua",
      "j-hui/fidget.nvim",
    },
    opts = {
      debug = false,
      auto_follow_cursor = true,
      display = {
        border = "rounded",
        chat = {
          show_header_separator = true,
          separator = "─",
          show_references = true,
          show_settings = false,
          show_token_count = true,
          start_in_insert_mode = true,
          window = {
            layout = "vertical",
            width = 0.23,
            position = "right",
          },
        },
      },
      keymaps = {
        close = "q",
        accept = "<CR>",
        toggle_diff_view = "<leader>td",
      },
      strategies = {
        chat = {
          adapter = "copilot",
          roles = {
            llm = function(adapter)
              return "  CodeCompanion (" .. adapter.formatted_name .. ")"
            end,
            user = "  Me",
          },
        },
        inline = {
          adapter = "copilot",
        },
      },
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              --  NOTE: 通常時はpremium requestを抑えたいのでデフォルトモデルを利用する. モデルを切り替えるときは `<ga>` でchange adapterする
              -- https://docs.github.com/en/copilot/managing-copilot/monitoring-usage-and-entitlements/about-premium-requests#model-multipliers
              max_tokens = {
                default = 120000, -- デフォは15000
              },
            },
          })
        end,
      },
      opts = {
        language = "Japanese",
      },
    },
    keys = {
      { "<leader>co", "<cmd>CodeCompanion<CR>", desc = "CodeCompanion" },
      { "<leader>ca", "<cmd>CodeCompanionAction<CR>", desc = "Explain Code" },
      { "<leader>ct", "<cmd>CodeCompanionChat<CR>", desc = "Toggle CodeCompanion" },
    },
    init = function()
      require("plugins.custom.spinner"):init()
    end,
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
    },
    -- comment the following line to ensure hub will be ready at the earliest
    cmd = "MCPHub", -- lazy load by default
    build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    config = function()
      require("mcphub").setup()
    end,
  },
}
