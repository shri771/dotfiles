return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- This function runs and adds gopls to your setup
    local lspconfig = require("lspconfig")

    lspconfig.gopls.setup({
      cmd = { "gopls" }, -- Use Nix-installed gopls
      settings = {
        gopls = {
          -- experimentalWorkspaceModule = true,
          analyses = {
            unusedparams = true,
            shadow = true,
            unusedwrite = true,
            useany = true,
          },
          staticcheck = true,
          gofumpt = true,
          usePlaceholders = true,
          completeUnimported = true,
          matcher = "Fuzzy",
          experimentalPostfixCompletions = true,
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
        },
      },
    })
  end,
}
