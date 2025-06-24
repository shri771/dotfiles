-- move slected text
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '< -2<CR>gv=gv")

-- allow the cursor to stay at the staring of line when appending text up
vim.keymap.set("n", "J", "mzJ'z")
vim.keymap.set("v", "y", "y`>", { noremap = true, silent = true, desc = "Yank and go to end" })

-- -- keep the cursor in center when searching, and never drop into Visual on repeated taps
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true, nowait = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true, silent = true, nowait = true })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- undotree --
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Clipborad --
vim.keymap.set("n", "p", ":put<CR>", { noremap = true, silent = true })

-- Debugger --
-- make sure dap is required up top:
local dap = require("dap")

-- Formattinp Error

-- Map <leader>i in normal mode to :ConformInfo
vim.keymap.set("n", "<leader>e", function()
  vim.cmd("ConformInfo")
end, { desc = "Show ConformInfo", silent = true })
vim.keymap.set("n", "<leader>w", function()
  vim.cmd("write")
end, { desc = "Save buffer", silent = true })
vim.keymap.set("n", "<leader>x", function()
  vim.cmd("x")
end, { desc = "Save and exit ", silent = true })
vim.keymap.set("n", "<leader>q!", function()
  vim.cmd("q!")
end, { desc = "Save buffer", silent = true })
