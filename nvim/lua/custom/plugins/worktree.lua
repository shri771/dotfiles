return {
  "ThePrimeagen/git-worktree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    -- 1. Load the extension
    require("telescope").load_extension("git_worktree")

    -- 2. global setup (optional, default is fine)
    require("git-worktree").setup({
      change_directory_command = "cd", -- default: "cd",
      update_on_change = true, -- default: true,
      update_on_change_command = "e .", -- default: "e .",
      clearjumps_on_change = true, -- default: true,
      autopush = false, -- default: false,
    })
  end,
}
