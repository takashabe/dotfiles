return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- for Telescope
    { "<Leader><space>", "<cmd>Telescope<CR>", mode = { "n" }, desc = "Builtin Pickers" },
    { "<Leader>/", "<Cmd>Telescope live_grep<CR>", mode = { "n" }, desc = "Grep" },
    { "<Leader>:", "<Cmd>Telescope command_history<CR>", mode = { "n" }, desc = "Command History" },

    -- find
    { "<Leader>ff", "<Cmd>Telescope fd<CR>", mode = { "n" } },
    { "<Leader>fg", "<Cmd>Telescope git_files<CR>", mode = { "n" } },
    { "<Leader>fb", "<Cmd>Telescope buffers<CR>", mode = { "n" } },
    { "<Leader>fr", "<Cmd>Telescope resume<CR>", mode = { "n" } },
    { "<Leader>fn", "<Cmd>Telescope notify<CR>", mode = { "n" } },
    { "<Leader>fh", "<Cmd>Telescope help_tags<CR>", mode = { "n" } },
    { "<Leader>fd", "<Cmd>Telescope diagnostics<CR>", mode = { "n" } },
    { '<Leader>f"', "<cmd>Telescope registers<CR>", mode = { "n" } },

    -- for Git
    { "<Leader>gs", "<Cmd>Telescope git_status<CR>", mode = { "n" } },
    { "<Leader>gb", "<Cmd>Telescope git_branches<CR>", mode = { "n" } },
  },
}
