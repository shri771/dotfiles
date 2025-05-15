vim.g.have_nerd_font = true
vim.opt.foldenable = false
vim.opt.number = true

vim.opt.shiftwidth = 4        
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
vim.o.undolevels = 1000000
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

vim.g.python3_host_prog = '/usr/bin/python3'

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

-- Prevent changed text to clipboard
vim.keymap.set('n', 'c', '"_c', { noremap = true })

--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- allow mappings to wait
vim.o.timeout = true

-- time (in ms) Neovim waits after you press <Leader>
-- default is 1000ms (1s); bump it to 1500 (1.5s) or whatever you like
vim.o.timeoutlen = 1500


-- Sync the terminal theme with nvim
vim.api.nvim_create_autocmd({ 'UIEnter', 'ColorScheme' }, {
	callback = function()
		local normal_bg = vim.api.nvim_get_hl_by_name('Normal', true).background
		if normal_bg then
			local bg_color = string.format('#%06x', normal_bg)
			io.write(string.format('\027]11;%s\027\\', bg_color))
		end
	end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank {
      higroup = 'IncSearch',
      timeout = 100,
    }
  end,
})



-- Saves the current cursor position in a file, including files opened via file search
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = { '*' },
  callback = function()
    local ft = vim.bo.filetype
    local last_known_line, last_known_col = unpack(vim.api.nvim_buf_get_mark(0, '"'))

    -- Check if the file type is not 'commit' or 'rebase' and the last position is valid
    if not (ft:match 'commit' or ft:match 'rebase') and last_known_line > 0 and last_known_line <= vim.api.nvim_buf_line_count(0) then
      -- Move the cursor to the last position, preserving both line and column
      vim.api.nvim_win_set_cursor(0, { last_known_line, last_known_col })
    end
  end,
})




-- Set backspace in netrw mode to go back dir
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'netrw',
  callback = function(args)
    local opts = { buffer = args.buf, silent = true, remap = true }

    -- Backspace = go up (same as pressing '-')
    vim.keymap.set('n', '<BS>', '-', opts)

    -- If you want Backspace to go back in history instead, use:
    -- vim.keymap.set("n", "<BS>", "u", opts)

    -- Or, map another key (e.g. <leader>- ) to parent:
    -- vim.keymap.set("n", "<leader>-", "-", opts)
  end,
})

