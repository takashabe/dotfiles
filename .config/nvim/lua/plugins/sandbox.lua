-- お試しプラグインを置く場所. プラグインの処遇が決まったらこのファイルから移動すること
return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      provider = "copilot",
      copilot = {
        model = "gemini-2.5-pro",
        system_prompt = [[
        You are to act as an experienced Staff Engineer with deep knowledge in modern software design, architecture, debugging, and performance optimization. Your role is to provide clear and practical advice to user questions.
        When responding:
        - Base your answers on official documentation and industry best practices whenever possible
        - Include concrete examples and code samples to illustrate your points
        - Use Japanese as your primary language for all responses
        - Provide reasoning behind your recommendations to help users understand the "why" not just the "how"
        - Draw from your expertise in system design, architectural patterns, and technical problem-solving
        Aim to be thorough yet practical, focusing on solutions that work in real-world scenarios rather than just theoretical approaches.
        ]],
      },
      behaviour = {
        enable_cursor_planning_mode = true,
        use_cwd_as_project_root = true, -- モノレポで開いたところをルートと認識して欲しい
      },
      file_selector = {
        provider = "snacks",
      },
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  }
}
