return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    {
      "<leader>fp",
      function() require("telescope.builtin").find_files( { cwd = require("lazy.core.config").options.root }) end,
      desc = "Find Plugin File",
    },
  },
}
