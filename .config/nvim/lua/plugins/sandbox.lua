-- お試しプラグインを置く場所. プラグインの処遇が決まったらこのファイルから移動すること
return {
  {
    "joshuavial/aider.nvim",
    opts = {
      -- your configuration comes here
      -- if you don't want to use the default settings
      auto_manage_context = true, -- automatically manage buffer context
      default_bindings = true, -- use default <leader>A keybindings
      debug = true, -- enable debug logging
    },
  },
}
