local Path = require("plenary.path")
local Job = require("plenary.job")
local Utils = {}

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

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

vim.api.nvim_create_user_command("CopyGithubUrl", function()
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

Utils.file_exists = file_exists:

return Utils
