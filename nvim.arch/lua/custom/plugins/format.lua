return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        -- Customize or remove this keymap to your liking
        "<leader>f",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" }, -- Added gofumpt for stricter formatting
        lua = { "stylua" },
        python = { "isort", "black" },
        html = { "prettier" },
        javascript = { "prettierd", "prettier" },
        c = { "clang-format" },
        bash = { "shfmt" },
        sql = { "sql-formatter" },
      },
      -- Set default options
      default_format_opts = {
        lsp_format = "fallback",
      },
      -- Set up format-on-save
      format_on_save = { timeout_ms = 500 },
      -- Customize formatters
      formatters = {
        ["sql-formatter"] = {
          command = "sql-formatter",
          args = { "--language", "postgresql" },
          stdin = true,
        },
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
