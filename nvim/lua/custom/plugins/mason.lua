return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "bashls",
          "jsonls",
          "pyright",
          "gopls",
          "html",
          "dockerfile-language-server-nodejs",
          "yamlls",
          "marksman",
        },
      })
    end,
  },
}
