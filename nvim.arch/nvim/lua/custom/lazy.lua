-- ~/.config/nvim/lua/custom/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("custom.plugins", {
  -- optional improvements:
  defaults = { lazy = true, version = "*" },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true, notify = false }, -- auto‑update check
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "matchit" },
    },
  },
})
