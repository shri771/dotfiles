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
vim.keymap.set("n", "<leader>ml", "<cmd>Mason<cr>")
vim.keymap.set("n", "<leader>mm", "<cmd>Lazy<cr>")
vim.keymap.set("i", "<C-^>", "<C-o><C-^>")

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Quickfix
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>rg", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>rr", [[:%s/\<<C-r><C-w>\>//gIc<Left><Left><Left><Left>]])
vim.keymap.set("n", "<leader>-", "<cmd>!chmod +x %<CR>", { silent = true })

-- undotree --
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
local opts = { noremap = true, silent = true }

-- vim.api.nvim_set_keymap("n", ";", ",", opts)
-- vim.api.nvim_set_keymap("n", ",", ";", opts)
-- -- visual mode
-- vim.api.nvim_set_keymap("v", ";", ",", opts)
-- vim.api.nvim_set_keymap("v", ",", ";", opts)

local dap = require("dap")

vim.keymap.set("n", "c", '"_c', { noremap = true })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Map <leader>i in normal mode to :ConformInfo
vim.keymap.set("n", "<leader>e", function()
  vim.cmd("ConformInfo")
end, { desc = "Show ConformInfo", silent = true })
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", {
  desc = "Save buffer",
  silent = true,
})

vim.keymap.set("n", "<leader>@", function()
  local fullpath = vim.fn.expand("%:p") -- get full path
  vim.fn.setreg("+", fullpath) -- copy to system clipboard
  vim.notify("Copied: " .. fullpath) -- nice popup (needs Neovim ≥0.5)
end, { desc = "Copy current file path to clipboard", silent = true })

-- Define the keys you want to disable
local keys_to_disable = { "<Up>", "<Down>", "<Left>", "<Right>" }

-- Loop through the keys and disable them in all desired modes
for _, key in ipairs(keys_to_disable) do
  vim.keymap.set({ "n", "v", "i" }, key, "<Nop>", { noremap = true, silent = true })
end
