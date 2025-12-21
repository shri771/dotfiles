return {
  {
    -- Added nvim-lint for dedicated linting support
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Configure linters by filetype
      lint.linters_by_ft = {
        python = { "ruff", "mypy" }, -- Added ruff (fast) and mypy (types)
        javascript = { "eslint_d" }, -- Added eslint_d
        typescript = { "eslint_d" }, -- Added eslint_d
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        -- go = { "golangcilint" }, -- Added golangci-lint (industry standard)

        sh = { "shellcheck" }, -- Added shellcheck
        bash = { "shellcheck" },
        yaml = { "yamllint" }, -- Added yamllint
        json = { "jsonlint" }, -- Added jsonlint
        dockerfile = { "hadolint" }, -- Added hadolint
        markdown = { "markdownlint" }, -- Added markdownlint
      }

      -- Auto-trigger linting
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
