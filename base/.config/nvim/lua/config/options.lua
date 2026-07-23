-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

vim.g.snacks_animate = false

opt.clipboard = {}
opt.ttimeoutlen = 10
opt.title = true
opt.scrolloff = 10

vim.diagnostic.config({
  virtual_text = false,
})
