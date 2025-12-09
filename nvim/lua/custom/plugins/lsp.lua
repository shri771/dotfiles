return {
  { "Bilal2453/luvit-meta", enabled = false, lazy = true },

  -- Go.nvim for enhanced Go development
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        lsp_cfg = false, -- Use your LSP config below
        lsp_keymaps = false,
        lsp_inlay_hints = {
          enable = true,
          style = "eol",
        },
        auto_format = true,
        auto_lint = true,
        run_in_floaterm = true,
        dap_debug = true,
        dap_debug_gui = true,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },

  {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", opts = {}, lazy = false },
      { "williamboman/mason-lspconfig.nvim", lazy = false },
      { "WhoIsSethDaniel/mason-tool-installer.nvim", lazy = false },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "luvit-meta/library", words = { "vim%.uv" } },
          },
        },
      },
      "saghen/blink.cmp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Keymaps
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Document highlighting
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          -- Inlay hints
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      -- Diagnostics configuration
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      })

      -- Get completion capabilities from Blink
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- LSP servers configuration
      local servers = {
        clangd = {},
        marksman = {},

        -- Enhanced Go configuration
        gopls = {
          settings = {
            gopls = {
              experimentalWorkspaceModule = true,
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
        },

        pyright = {},
        html = {}, -- Added HTML LSP (replaces htmlhint)
        bashls = {},
        
        -- Added missing industry standard LSPs
        ts_ls = {}, -- Added TypeScript/JavaScript LSP
        jsonls = {}, -- Added JSON LSP
        yamlls = {}, -- Added YAML LSP
        cssls = {}, -- Added CSS LSP
        dockerls = {}, -- Added Docker LSP
        taplo = {}, -- Added TOML LSP

        -- SQL with proper configuration
        sqls = {
          settings = {
            sqls = {
              connections = {
                {
                  driver = "postgresql",
                  dataSourceName = "postgres://postgres:postgres@localhost:5432/chirpy?sslmode=disable",
                },
              },
            },
          },
        },

        glint = {},


        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})

      -- Formatters and linters (LSP servers auto-installed by mason-lspconfig)
      vim.list_extend(ensure_installed, {
        "prettier",
        "stylua",
        "black",
        "isort",
        "clang-format",
        "google-java-format",
        "goimports",
        "gofumpt", -- Better Go formatting
        "sql-formatter",
        "cbfmt",
        
        -- Added Linters (configured in lint.lua)
        "ruff", -- Python fast linter
        "mypy", -- Python type checker
        "eslint_d", -- JS/TS linter
        "golangci-lint", -- Go meta-linter

        "shellcheck", -- Shell linter
        "yamllint", -- YAML linter
        "hadolint", -- Dockerfile linter
        "markdownlint", -- Markdown linter
        "jsonlint", -- JSON linter
        "stylelint", -- CSS linter
      })

      require("mason-tool-installer").setup({
        ensure_installed = ensure_installed,
        auto_update = false,
        run_on_start = true,
      })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },
}
