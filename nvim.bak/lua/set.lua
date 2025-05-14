vim.g.have_nerd_font = true
vim.opt.foldenable = false
vim.opt.number = true

--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath 'config' .. '/undo'
vim.o.undolevels = 10000
-- Make sure the undo directory exists
if not vim.fn.isdirectory(vim.fn.stdpath 'config' .. '/undo') then
  vim.fn.mkdir(vim.fn.stdpath 'config' .. '/undo', 'p')
end

-- Ignorecase if all is lower cap
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default (beside the number bar)
vim.opt.signcolumn = 'yes'

-- Decrease update time (in milliseconds)
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 15
