-- お試しプラグインを置く場所. プラグインの処遇が決まったらこのファイルから移動すること
return {
  {
    "jellydn/codecompanion.nvim",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "stevearc/dressing.nvim", -- public archiveされているので依存が消えたら削除する. checkhealthで確認する.
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
        },
      },
    },
    config = function(_, opts)
      require("codecompanion").setup(opts)

      -- キーマッピングの設定例
      vim.keymap.set("n", "<leader>caa", ":CodeCompanion<CR>", { desc = "Open Code Companion" })
      vim.keymap.set("v", "<leader>cae", ":CodeCompanionExplain<CR>", { desc = "Explain Code" })
      vim.keymap.set("v", "<leader>car", ":CodeCompanionRefactor<CR>", { desc = "Refactor Code" })
    end,
    event = "VeryLazy",
  },
}
