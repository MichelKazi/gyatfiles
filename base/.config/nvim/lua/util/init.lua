---@class Util
---@field git UtilGit
---@field diagnostics UtilDiagnostics
---@field highlights UtilHighlights
local M = {}

-- =============================================================================
-- Git Utilities
-- =============================================================================

---@class UtilGit
M.git = {}

---Get the git root directory for the current file
---@return string|nil
function M.git.get_root()
  local Job = require("plenary.job")
  local result = Job:new({
    command = "git",
    args = { "rev-parse", "--show-toplevel" },
    cwd = vim.fn.expand("%:p:h"),
  }):sync()
  return result[1]
end

---Get the relative path from git root
---@return string|nil
function M.git.get_relative_path()
  local Path = require("plenary.path")
  local git_root = M.git.get_root()
  if not git_root then
    return nil
  end
  local current_file = vim.fn.expand("%:p")
  return Path:new(current_file):make_relative(git_root)
end

---Check if an executable is installed
---@param executable string
---@return boolean
local function is_installed(executable)
  if vim.fn.executable(executable) == 0 then
    vim.api.nvim_err_writeln("Error: " .. executable .. " CLI is not installed.")
    return false
  end
  return true
end

---Get the GitHub repo URL using gh CLI
---@return string|nil
function M.git.get_github_repo_url()
  if not (is_installed("gh") and is_installed("jq")) then
    return nil
  end
  local command = "gh repo view --json url -q \".url\" | awk '{print($0)}' | column"
  local output = vim.fn.system(command)
  return vim.fn.trim(output)
end

---Copy GitHub URL to clipboard (optionally with line number)
---@param include_line boolean Whether to include the current line number
function M.git.copy_github_url(include_line)
  local notify = require("snacks.notify")
  local repo = M.git.get_github_repo_url()
  local filepath = M.git.get_relative_path()

  if not (repo and filepath) then
    notify.error("Failed to retrieve GitHub URL")
    return
  end

  local url = repo .. "/blob/main/" .. filepath
  if include_line then
    url = url .. "#L" .. vim.fn.line(".")
  end

  vim.fn.setreg("+", url)
  notify(url .. " copied to clipboard")
end

---Extract JIRA ticket from branch and update commit message
---Called on gitcommit filetype
function M.git.setup_commit_message()
  local snacks = require("snacks")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  if not (lines[1] and lines[1]:match("^%[JIRA%-#%]")) then
    return
  end

  local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
  local ticket = branch:match("^[^/]+/([^/]+)")

  if ticket and ticket ~= "" then
    for i, line in ipairs(lines) do
      lines[i] = line:gsub("JIRA%-#", ticket)
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    snacks.notify("Replaced JIRA-# with " .. ticket)
  end

  local title_start = lines[1]:find("%]%s*") or 0
  if title_start > 0 then
    vim.api.nvim_win_set_cursor(0, { 1, title_start })
  end
end

-- =============================================================================
-- Diagnostics Utilities
-- =============================================================================

---@class UtilDiagnostics
M.diagnostics = {}

---Toggle diagnostics for the current buffer
function M.diagnostics.toggle()
  local buf = vim.api.nvim_get_current_buf()
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled, { bufnr = buf })
end

---Open diagnostic float, yank content, and close
function M.diagnostics.yank_error()
  vim.diagnostic.open_float()
  vim.diagnostic.open_float()
  local win_id = vim.fn.win_getid()
  vim.cmd("normal! j")
  vim.cmd("normal! VG")
  vim.cmd("normal! y")
  vim.api.nvim_win_close(win_id, true)
end

-- =============================================================================
-- Highlight Utilities
-- =============================================================================

---@class UtilHighlights
M.highlights = {}

---Blue gradient colors for lines above (index 1 = closest to cursor, brightest)
local blue_gradient = {
  "#7DC4FF", -- 1 line away (brightest)
  "#6BB5F0",
  "#59A6E1",
  "#4797D2",
  "#3588C3",
  "#2379B4",
  "#116AA5",
  "#005B96",
  "#004C87", -- 9+ lines away (darkest)
}

---Red gradient colors for lines below (index 1 = closest to cursor, brightest)
local red_gradient = {
  "#FF7D7D", -- 1 line away (brightest)
  "#F06B6B",
  "#E15959",
  "#D24747",
  "#C33535",
  "#B42323",
  "#A51111",
  "#960505",
  "#870000", -- 9+ lines away (darkest)
}

---Set custom line number colors with gradients (above=blue, below=red)
function M.highlights.set_line_number_colors()
  -- Current line number
  vim.api.nvim_set_hl(0, "LineNr", { fg = "white", bold = true })

  -- Create gradient highlight groups for lines above (blue)
  for i, color in ipairs(blue_gradient) do
    vim.api.nvim_set_hl(0, "LineNrAbove" .. i, { fg = color, bold = true })
  end

  -- Create gradient highlight groups for lines below (red)
  for i, color in ipairs(red_gradient) do
    vim.api.nvim_set_hl(0, "LineNrBelow" .. i, { fg = color, bold = true })
  end

  -- Fallback groups for compatibility
  vim.api.nvim_set_hl(0, "LineNrAbove", { fg = blue_gradient[#blue_gradient], bold = true })
  vim.api.nvim_set_hl(0, "LineNrBelow", { fg = red_gradient[#red_gradient], bold = true })
end

---Get the highlighted line number for statuscolumn
---@return string
function M.highlights.gradient_line_nr()
  local lnum = vim.v.lnum
  local cursor_line = vim.fn.line(".")
  local relnum = vim.v.relnum

  if relnum == 0 then
    -- Current line - show absolute number
    return "%#LineNr#" .. lnum
  end

  -- Clamp distance to gradient range (1-9)
  local distance = math.min(relnum, #blue_gradient)

  if lnum < cursor_line then
    -- Lines above cursor (blue gradient)
    return "%#LineNrAbove" .. distance .. "#" .. relnum
  else
    -- Lines below cursor (red gradient)
    return "%#LineNrBelow" .. distance .. "#" .. relnum
  end
end

---Enable gradient line numbers by setting statuscolumn
function M.highlights.enable_gradient_line_numbers()
  M.highlights.set_line_number_colors()
  vim.opt.statuscolumn = "%s%=%{%v:lua.require'util'.highlights.gradient_line_nr()%} "
end

---Invert visual selection colors
function M.highlights.invert_visual_selection()
  vim.api.nvim_set_hl(0, "Visual", { bg = "black", bold = true })
end

---Set dashboard header color
function M.highlights.set_dashboard_header()
  vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#fc5200", force = true })
end

---Force transparent background (use terminal bg)
function M.highlights.set_transparent_background()
  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
end

---Set up active window indication
function M.highlights.setup_active_window_indicator()
  -- Create a dimmed Normal for inactive windows
  vim.api.nvim_set_hl(0, "NormalNC", { fg = "#666666", bg = "NONE" })

  -- Bright cursorline for active window
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2a2a2a" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true })

  -- Set a visible window separator
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#ff5f00", bg = "NONE" })

  local augroup = vim.api.nvim_create_augroup("ActiveWindowIndicator", { clear = true })

  -- Enable cursorline only in active window
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FocusGained" }, {
    group = augroup,
    callback = function()
      vim.opt_local.cursorline = true
    end,
  })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "FocusLost" }, {
    group = augroup,
    callback = function()
      vim.opt_local.cursorline = false
    end,
  })
end

---Colorscheme-specific highlight overrides
---@type table<string, fun()>
M.highlights.colorscheme_overrides = {
  srcery = function()
    vim.api.nvim_set_hl(0, "Operator", { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "Delimiter", { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "Special", { fg = "#FF0000" })
  end,
  -- Add overrides for other colorschemes as needed:
  -- gruvbox = function() end,
  -- catppuccin = function() end,
  -- cyberdream = function() end,
}

---Apply colorscheme-specific highlight overrides
function M.highlights.apply_colorscheme_overrides()
  -- Always use terminal background
  M.highlights.set_transparent_background()

  -- Set up active window indicator (dimmed inactive + cursorline + visible separator)
  M.highlights.setup_active_window_indicator()

  -- Apply colorscheme-specific overrides
  local colorscheme = vim.g.colors_name
  local override_fn = M.highlights.colorscheme_overrides[colorscheme]
  if override_fn then
    override_fn()
  end
end

return M
