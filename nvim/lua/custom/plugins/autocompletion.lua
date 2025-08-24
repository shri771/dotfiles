return {
  { -- Autocompletion
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "1.*",
    build = "make",
    dependencies = {
      {
        "fang2hou/blink-copilot",
        opts = {
          max_completions = 1, -- Global default for max completions
          max_attempts = 2, -- Global default for max attempts
        },
      },
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
        opts = {},
      },
      "folke/lazydev.nvim",
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },

        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },
      cmdline = {
        enabled = true,
        completion = {
          menu = { auto_show = true },
          list = {
            selection = { preselect = false, auto_insert = true },
          },
        },
      },
      signature = { enabled = false },
      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        ghost_text = { enabled = false },
        menu = {
          draw = {
            padding = { 0, 1 }, -- padding only on right side
            treesitter = { "lsp" },
            columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
            components = {
              kind_icon = {
                text = function(ctx)
                  if ctx.item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
                    return " "
                  end
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                highlight = function(ctx)
                  if ctx.item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
                    vim.api.nvim_set_hl(0, "BlinkCmpKindSnippet", { fg = "#f4ff21" })
                    return "BlinkCmpKindSnippet"
                  end
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { "snippets", "buffer", "lsp", "lazydev", "path", "copilot" },
        -- default = { "buffer", "lazydev", "path" }, -- No LSP
        providers = {
          buffer = {
            module = "blink.cmp.sources.buffer",
          },
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
            opts = {
              -- Local options override global ones
              max_completions = 3, -- Override global max_completions

              -- Final settings:
              -- * max_completions = 3
              -- * max_attempts = 2
              -- * all other options are default
            },
          },
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            transform_items = function(_, items)
              return vim.tbl_filter(function(item)
                return item.kind ~= require("blink.cmp.types").CompletionItemKind.Keyword
              end, items)
            end,
          },
          cmdline = {
            min_keyword_length = function(ctx)
              -- when typing a command, only show when the keyword is 3 characters or longer
              if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
                return 3
              end
              return 0
            end,
          },
        },
      },

      snippets = { preset = "luasnip" },

      fuzzy = { implementation = "rust" },

      -- Shows a signature help window while you type arguments for a function
    },
  },
}
