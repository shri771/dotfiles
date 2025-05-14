return 
{

  { 'ThePrimeagen/vim-be-good' },
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },


  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    lazy     = false,    -- ← load immediately
    priority = 1000,     -- still make sure it comes before everything else
    config = function()
      local statusline = require 'mini.statusline'
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
 -- adds signs 
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

}  
