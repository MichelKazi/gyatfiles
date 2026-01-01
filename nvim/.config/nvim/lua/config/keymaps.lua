-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local Util = require("lazyvim.util")
local map = Util.safe_keymap_set
local util = require("util")

-- Create user command for copying GitHub URLs
vim.api.nvim_create_user_command("CopyGithubUrl", function()
  util.git.copy_github_url(false)
end, { desc = "Copy file GitHub URL" })

vim.api.nvim_create_user_command("CopyGithubUrlWithLine", function()
  util.git.copy_github_url(true)
end, { desc = "Copy file GitHub URL with line number" })

-- Clear search highlight
map("n", "<esc><esc>", function()
  vim.cmd("noh")
end, { desc = "Clear hlsearch" })

-- System clipboard operations
map("n", "<leader>d", '"+d')
map("v", "<leader>d", '"+d')
map("n", "<leader>D", '"+D')

map("n", "<leader>c", '"+c')
map("v", "<leader>c", '"+c')
map("n", "<leader>C", '"+C')

map("n", "<leader>y", '"+y')
map("v", "<leader>y", '"+y')
map("n", "<leader>Y", '"+Y')

map("n", "<C-y>", function()
  vim.cmd("let @+ = expand('%p')")
end, { desc = "Copy file path" })

map("n", "<leader>gy", function()
  util.git.copy_github_url(false)
end, { desc = "Copy GitHub URL" })

map("n", "<leader>gY", function()
  util.git.copy_github_url(true)
end, { desc = "Copy GitHub URL with line" })

map("n", "<leader>p", '"+p')
map("v", "<leader>p", '"+p')
map("n", "<leader>P", '"+P')

-- Neotest
map("n", "<leader>tt", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })

map("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run test file" })

map("n", "<leader>tl", function()
  require("neotest").run.run_last()
end, { desc = "Run last test" })

map("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "Toggle test summary" })

map("n", "<leader>to", function()
  require("neotest").output.open({ enter = true })
end, { desc = "Open test output" })

map("n", "<leader>tp", function()
  require("neotest").output_panel.toggle()
end, { desc = "Toggle output panel" })

map("n", "[t", function()
  require("neotest").jump.prev({ status = "failed" })
end, { desc = "Previous failed test" })

map("n", "]t", function()
  require("neotest").jump.next({ status = "failed" })
end, { desc = "Next failed test" })

map("n", "<leader>te", function()
  require("neotest-metals").show_error()
end, { desc = "Show test error" })

-- Diagnostics
map("n", "<leader>Dt", util.diagnostics.toggle, { desc = "Toggle diagnostics" })
map("n", "<leader>e", util.diagnostics.yank_error, { noremap = true, silent = true, desc = "Copy error" })

-- File explorer
map("n", "<C-n>", function()
  Snacks.picker.explorer({ follow_file = true })
end, { desc = "File explorer" })

-- dial.nvim increment/decrement
map("n", "<C-a>", function()
  require("dial.map").manipulate("increment", "normal")
end)
map("n", "<C-x>", function()
  require("dial.map").manipulate("decrement", "normal")
end)
map("n", "g<C-a>", function()
  require("dial.map").manipulate("increment", "gnormal")
end)
map("n", "g<C-x>", function()
  require("dial.map").manipulate("decrement", "gnormal")
end)
map("v", "<C-a>", function()
  require("dial.map").manipulate("increment", "visual")
end)
map("v", "<C-x>", function()
  require("dial.map").manipulate("decrement", "visual")
end)
map("v", "g<C-a>", function()
  require("dial.map").manipulate("increment", "gvisual")
end)
map("v", "g<C-x>", function()
  require("dial.map").manipulate("decrement", "gvisual")
end)
