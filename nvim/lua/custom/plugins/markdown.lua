return {
  -- render-markdown.nvim: Beautifies markdown in-buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- glow.nvim: Floating preview window using glow CLI
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    opts = {},
  },

  -- img-clip.nvim: Paste images from clipboard into markdown
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },

  -- ltex.nvim: Grammar/spell checking LSP (wraps ltex-ls + LanguageTool)
  {
    "erooke/ltex.nvim",
    ft = { "markdown", "text", "latex", "bibtex" },
    opts = {},
  },
}
