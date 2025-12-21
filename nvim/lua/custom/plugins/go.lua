return {
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- Setup go.nvim WITHOUT any LSP features - gopls is configured in lsp.lua
      require("go").setup({
        lsp_cfg = false,
        lsp_keymaps = false,
        lsp_codelens = false,
        lsp_on_attach = false,
        lsp_inlay_hints = {
          enable = false,
        },
        diagnostic = false,
        auto_format = false,
        auto_lint = false,
        run_in_floaterm = true,
        dap_debug = true,
        dap_debug_gui = true,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },
}
