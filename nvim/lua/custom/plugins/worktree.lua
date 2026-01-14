return {
  "ThePrimeagen/git-worktree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local Worktree = require("git-worktree")

    -- 1. Load the extension
    require("telescope").load_extension("git_worktree")

    -- 2. global setup (optional, default is fine)
    Worktree.setup({
      change_directory_command = "cd", -- default: "cd",
      update_on_change = true, -- default: true,
      update_on_change_command = "e .", -- default: "e .",
      clearjumps_on_change = true, -- default: true,
      autopush = false, -- default: false,
    })

    -- 3. Store current path before switch, apply lcd after
    _G._worktree_prev_path = vim.fn.getcwd()

    Worktree.on_tree_change(function(op, _)
      if op == Worktree.Operations.Switch then
        local prev = _G._worktree_prev_path
        -- Schedule lcd to run after the switch completes
        vim.schedule(function()
          if prev then
            vim.cmd("lcd " .. prev)
            vim.notify("lcd: " .. prev, vim.log.levels.INFO)
          end
          -- Update stored path to current (for next switch)
          _G._worktree_prev_path = vim.fn.getcwd()
        end)
      end
    end)
  end,
}
