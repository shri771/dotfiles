-- move slected text in Visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '< -2<CR>gv=gv")

vim.keymap.set("v", "y", "y`>", { noremap = true, silent = true, desc = "Yank and go to end" })

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap'a")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")
vim.keymap.set("n", "<leader>m", "<cmd>Mason<cr>")
vim.keymap.set("n", "<leader>mm", "<cmd>Lazy<cr>")

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>rg", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>rr", [[:%s/\<<C-r><C-w>\>//gIc<Left><Left><Left><Left>]])

-- undotree --
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- -- Clipborad --
-- vim.keymap.set("n", "p", ":put<CR>", { noremap = true, silent = true })

-- vim.keymap.set("n", "<leader><leader>", function()
--   vim.cmd("so")
-- end)
-- Debugger --
-- make sure dap is required up top:
local dap = require("dap")

-- Formattinp Error
vim.keymap.set("n", "<leader>-", "<cmd>!chmod +x %<CR>", { silent = true })

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
vim.keymap.set("n", "<leader>!", function()
  vim.cmd("q!")
end, { desc = "Save buffer", silent = true })
