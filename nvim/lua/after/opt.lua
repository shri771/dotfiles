-- Opt
vim.opt.mouse = ""

vim.g.have_nerd_font = true
vim.opt.foldenable = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.signcolumn = "yes"
vim.opt.shortmess:append("S")

vim.opt.list = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.scrolloff = 15
vim.o.timeout = true
vim.o.timeoutlen = 1700

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("config") .. "/undo"
vim.o.undolevels = 1000000

vim.g.python3_host_prog = "/usr/bin/python3"

vim.opt.inccommand = "split"
vim.opt.cursorline = true

-- AutoCmds
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({
      higroup = "IncSearch",
      timeout = 100,
    })
  end,
})

-- Save the Cursor postion
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*" },
  callback = function()
    local ft = vim.bo.filetype
    local last_known_line, last_known_col = unpack(vim.api.nvim_buf_get_mark(0, '"'))

    if
      not (ft:match("commit") or ft:match("rebase"))
      and last_known_line > 0
      and last_known_line <= vim.api.nvim_buf_line_count(0)
    then
      vim.api.nvim_win_set_cursor(0, { last_known_line, last_known_col })
    end
  end,
})

-- Clear echo area of cmd
vim.api.nvim_create_autocmd("CmdlineLeave", {
  callback = function()
    vim.defer_fn(function()
      if vim.fn.mode() ~= "c" then -- Only clear if we're not back in command-line mode
        vim.cmd("echo ''")
      end
    end, 2000)
  end,
})

-- Create an autocmd group to avoid duplicate mappings
vim.api.nvim_create_augroup("KeepVisualIndent", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.sql",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
