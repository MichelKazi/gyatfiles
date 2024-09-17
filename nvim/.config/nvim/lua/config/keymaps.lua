-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local Util = require("lazyvim.util")

local map = Util.safe_keymap_set
local splits = require("smart-splits")

vim.api.nvim_create_user_command("CopyGithubUrl", function()
  local Path = require("plenary.path")
  local Job = require("plenary.job")

  local function get_git_root()
    local result = Job:new({
      command = "git",
      args = { "rev-parse", "--show-toplevel" },
      cwd = vim.fn.expand("%:p:h"),
    }):sync()

    return result[1]
  end

  local function get_relative_path_from_git_root()
    local git_root = get_git_root()
    if not git_root then
      return nil
    end

    local current_file = vim.fn.expand("%:p")
    local relative_path = Path:new(current_file):make_relative(git_root)

    return relative_path
  end

  local function is_installed(executable)
    if vim.fn.executable(executable) == 0 then
      vim.api.nvim_err_writeln("Error: " .. executable .. " CLI is not installed. Please install it to proceed.")
      return false
    end
    return true
  end

  local function get_gh_repo_url()
    local can_get_url = is_installed("gh") and is_installed("jq")
    if not can_get_url then
      return
    end

    local command = "gh repo view --json url -q \".url\" | awk '{print($0)}' | column"
    local output = vim.fn.system(command)

    -- Remove any trailing newline characters from the output
    output = vim.fn.trim(output)

    return output
  end

  local notify = require("notify")
  local repo = get_gh_repo_url()
  local filepath = get_relative_path_from_git_root()
  local url = repo .. "/blob/main/" .. filepath
  if repo and filepath then
    vim.fn.setreg("+", url)
  else
    notify("Failed to retrieve github url", "error")
  end
  notify(url .. " copied to clipboard")
end, { desc = "Copy file from github url" })

map("n", "<esc><esc>", function()
  require("notify").dismiss({ silent = true, pending = true })
end, { desc = "Redraw / clear hlsearch / diff update" })

map("n", "<C-n>", function()
  require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
end, { desc = "Toggle tree (cwd)" })

map("n", "<C-e>", function()
  require("neo-tree.command").execute({ toggle = true, dir = Util.root() })
end, { desc = "Toggle tree (cwd)" })

-- Cut (delete) and copy to system clipboard
map("n", "<leader>d", '"+d')
map("v", "<leader>d", '"+d')
map("n", "<leader>D", '"+D')

-- Change and copy to system clipboard
map("n", "<leader>c", '"+c')
map("v", "<leader>c", '"+c')
map("n", "<leader>C", '"+C')

-- Yank to system clipboard
map("n", "<leader>y", '"+y')
map("v", "<leader>y", '"+y')
map("n", "<leader>Y", '"+Y')
map("n", "<C-y>", function()
  vim.cmd("let @+ = expand('%p')")
end)
map("n", "<leader>gy", function()
  vim.cmd("CopyGithubUrl")
end)
--
-- Yank to system clipboard
map("n", "<leader>p", '"+p')
map("v", "<leader>p", '"+p')
map("n", "<leader>P", '"+P')

map("n", "<leader>tl", function()
  require("neotest").run.run_last()
end, { desc = "Run last test" })

map("n", "<leader>tw", function() end, { desc = "Run and watch tests" })

map("n", "<C-e>", function()
  splits.start_resize_mode()
end)

map("n", "<C-h>", function()
  splits.move_cursor_left()
end)

map("n", "<C-j>", function()
  splits.move_cursor_down()
end)

map("n", "<C-k>", function()
  splits.move_cursor_up()
end)

map("n", "<C-l>", function()
  splits.move_cursor_right()
end)

map("n", "<leader>md", function()
  local buf = vim.api.nvim_get_current_buf()
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled, { bufnr = buf })
end)
