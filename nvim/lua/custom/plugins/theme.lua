return {
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false, -- ← load immediately
  --   priority = 1000, -- still make sure it comes before everything else
  --   opts = {
  --     style = "night",
  --     transparent = true,
  --     styles = {
  --       floats = "transparent",
  --     },
  --   },
  --   config = function(_, opts)
  --     require("tokyonight").setup(opts)
  --     vim.cmd.colorscheme("tokyonight")
  --     vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
  --     vim.api.nvim_set_hl(0, "Float", { bg = "NONE" })
  --   end,
  -- },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000, -- Make sure it loads first
    opts = {
      -- Your 'style = "night"' from tokyonight translates to 'variant = "moon"' in rose-pine
      variant = "moon",

      -- This is the equivalent of tokyonight's 'transparent = true'
      disable_background = true,

      -- This is the equivalent of tokyonight's 'styles.floats = "transparent"'
      disable_float_background = true,
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)

      -- Apply the colorscheme
      vim.cmd.colorscheme("rose-pine")

      -- We keep your original highlight overrides to ensure floats are *definitely* transparent
      -- This is the same as your previous config.
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "Float", { bg = "NONE" })
    end,
  },
}
