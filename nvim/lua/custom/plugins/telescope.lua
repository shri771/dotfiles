return {
  {
    "nvim-telescope/telescope.nvim",
    tag    = "0.1.8",
    event  = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond  = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
      -- Useful for getting pretty icons, but requires a Nerd Font.
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },

    keys = {
      { "<leader>sf",      function() require("telescope.builtin").find_files() end,                    desc = "telescope find files"           },
      { "<leader>sg",      function() require("telescope.builtin").live_grep() end,                     desc = "telescope live grep"            },
      { "<leader><space>", function() require("telescope.builtin").buffers() end,                       desc = "telescope buffers"              },
      { "<leader>fh",      function() require("telescope.builtin").help_tags() end,                     desc = "telescope help tags"            },
      { "<leader>so",      function() require("telescope.builtin").oldfiles({ only_cwd = true }) end,   desc = "telescope oldfiles (cwd only)"  },
    },

    config = function()
      -- Basic setup from first config
      require("telescope").setup {
        defaults = {
          file_ignore_patterns = { "^undo/.*" },
        },
        -- extensions block from second config
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      }

      -- load extensions
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      -- extra keymaps from second config
      local builtin = require "telescope.builtin"
      vim.keymap.set("n", "<leader>sh", builtin.help_tags,     { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps,       { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin,       { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string,   { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics,   { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume,        { desc = "[S]earch [R]esume" })

      -- advanced dropdown search override
      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = "[/] Fuzzily search in current buffer" })

      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title     = "Live Grep in Open Files",
        }
      end, { desc = "[S]earch [/] in Open Files" })

      -- shortcut for nix config
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files { cwd = vim.fn.stdpath "config" }
      end, { desc = "[S]earch [N]eovim files" })
    end,
  },
}
