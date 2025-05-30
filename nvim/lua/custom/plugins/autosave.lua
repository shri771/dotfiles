return {
  {
    "folke/persistence.nvim",
    event = "VimEnter",
    opts = {
      dir = vim.fn.expand("$HOME/dotfiles/sessions/"),
      need = 2,
      branch = true,
    },
    config = function(_, opts)
      -- first, apply the opts
      require("persistence").setup(opts)

      -- then define your keymaps
      vim.keymap.set("n", "<leader>qs", function()
        require("persistence").load()
      end, { desc = "Session: load cwd" })
      vim.keymap.set("n", "<leader>qS", function()
        require("persistence").select()
      end, { desc = "Session: pick one" })
      vim.keymap.set("n", "<leader>ql", function()
        require("persistence").load({ last = true })
      end, { desc = "Session: load last" })
      vim.keymap.set("n", "<leader>qd", function()
        require("persistence").stop()
      end, { desc = "Session: stop autosave" })
    end,
  },
}
