-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local util = require("util")

-- Dashboard header color
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("DashboardHighlight", { clear = true }),
  callback = util.highlights.set_dashboard_header,
})

-- Disable autoformat for thrift files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "thrift",
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Git commit JIRA ticket extraction
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = util.git.setup_commit_message,
})

-- Line number colors and colorscheme-specific overrides
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    util.highlights.set_line_number_colors()
    util.highlights.apply_colorscheme_overrides()
  end,
})

-- Apply immediately since colorscheme already loaded before VeryLazy
util.highlights.set_line_number_colors()
util.highlights.apply_colorscheme_overrides()

-- LSP progress notifications (used by Metals and other LSP servers)
require("config.lsp-progress")
