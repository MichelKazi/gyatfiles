-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("DashboardHighlight", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#fc5200", force = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "thrift",
  callback = function()
    vim.b.autoformat = false
  end,
})

local git_commit = function()
  local snacks = require("snacks")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if lines[1] and lines[1]:match("^%[JIRA%-#%]") then
    -- Get current branch name
    local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
    -- Extract JIRA ticket from branch name (second item after splitting by /)
    local ticket = branch:match("^[^/]+/([^/]+)")
    -- Prompt for ticket number
    if ticket and ticket ~= "" then
      -- Replace all instances of JIRA-# with the actual ticket
      for i, line in ipairs(lines) do
        lines[i] = line:gsub("JIRA%-#", ticket)
      end
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      snacks.notify("Replaced JIRA-# with " .. ticket)
    end

    -- Move cursor to after the JIRA ticket on the first line
    local title_start = lines[1]:find("%]%s*") or 0
    if title_start > 0 then
      vim.api.nvim_win_set_cursor(0, { 1, title_start })
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = git_commit,
})

-- Sets colors to line numbers Above, Current and Below  in this order
function LineNumberColors()
  vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#51B3EC", bold = true })
  vim.api.nvim_set_hl(0, "LineNr", { fg = "white", bold = true })
  vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#FB508F", bold = true })
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = function()
    LineNumberColors()
  end,
})
