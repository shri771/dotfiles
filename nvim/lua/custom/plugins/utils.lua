return {

  {
    -- Auto-pairs & HTML tag completion
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true, -- enable Treesitter integration
      enable_tag = true, -- auto-close HTML tags (requires nvim-ts-autotag)
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("lualine").setup({
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "branch",
            "diff",
            { "diagnostics", sections = { "error", "warn", "info", "hint" } },
          },
          lualine_c = { { "filename", path = 0 } },
          lualine_x = {
            "searchcount",
            {
              "filetype",
              icon_only = true,
            },
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        tabline = {},
      })
    end,
  },
  {
    -- Treesitter-based auto-tagging for HTML/XML
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false, -- Auto close on trailing </
        },
        -- Also override individual filetype configs, these take priority.
        -- Empty by default, useful if one of the "opts" global settings
        -- doesn't work well in a specific filetype
        per_filetype = {
          ["html"] = {
            enable_close = false,
          },
        },
      })
    end,
  },
  {
    "editorconfig/editorconfig-vim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- No extra setup needed: it will read your .editorconfig automatically
    end,
  },

  {

    "nvim-treesitter/playground",
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = false,
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  },

  { "ThePrimeagen/vim-be-good", lazy = true, cmd = "VimBeGood" },

  {
    "norcalli/nvim-colorizer.lua",
    lazy = false,
    config = function()
      require("colorizer").setup()
    end,
  },

  { "mbbill/undotree", lazy = false },

  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  { -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    lazy = false,
    config = function()
      local statusline = require("mini.statusline")
      require("mini.ai").setup({ n_lines = 500 })
      -- require("mini.surround").setup()
      -- statusline.setup({ use_icons = vim.g.have_nerd_font })
      -- statusline.section_location = function()
      --   return "%2l:%-2v"
      -- end
    end,
  },
  -- adds signs
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
}
