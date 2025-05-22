return {
  {
    "folke/tokyonight.nvim",
    lazy = false, -- ← load immediately
    priority = 1000, -- still make sure it comes before everything else
    opts = {
      style = "night",
      transparent = true,
      styles = {
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "Float", { bg = "NONE" })
    end,
  },
}
