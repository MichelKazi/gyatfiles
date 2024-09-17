-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("DashboardHighlight", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#fc5200", force = true })
  end,
})
