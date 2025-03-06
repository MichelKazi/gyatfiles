-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: hthttps://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.luatps://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

vim.g.snacks_animate = false

opt.clipboard = {}
opt.clipboard = {}
opt.clipboard = {}

opt.ttimeoutlen = 10

opt.title = true
opt.scrolloff = 10

vim.diagnostic.config({
  virtual_text = false,
})
--
-- Sets colors to line numbers Above, Current and Below  in this order
function LineNumberColors()
  vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#51B3EC", bold = true })
  vim.api.nvim_set_hl(0, "LineNr", { fg = "white", bold = true })
  vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#FB508F", bold = true })
end

function InvertVisualSelectionColors()
  vim.api.nvim_set_hl(0, "Visual", { bg = "black", bold = true })
end

-- Show line diagnostics automatically in hover window
-- vim.o.updatetime = 250
-- vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
--
-- local colors = {
--   crust = "#11111b",
--   mantle = "#181825",
--   base = "#1e1e2e",
--   core = "#2c2c3f",
--
--   surface_0 = "#313244",
--   surface_1 = "#45475a",
--   surface_2 = "#585b70",
--
--   overlay_0 = "#6c7086",
--   overlay_1 = "#7f849c",
--   overlay_2 = "#9399b2",
--
--   subtext_0 = "#a6adc8",
--   subtext_1 = "#bac2de",
--   subtext_2 = "#cdd6f4",
--   text = "#f0f4ff",
--
--   blue = "#a4b9ef",
--   blue_dark = "#5f8cfb",
--   primary = "#a4b9ef",
--   primary_dark = "#5f8cfb",
--
--   lavender = "#b4befe",
--   lavender_dark = "#7f8cfe",
--
--   sapphire = "#74c7ec",
--   sapphire_dark = "#4a9edc",
--
--   sky = "#89dceb",
--   sky_dark = "#5f9edc",
--
--   teal = "#94e2d5",
--   teal_dark = "#5fb9a8",
--
--   green = "#a6e3a1",
--   green_dark = "#5fbf6b",
--
--   yellow = "#f9e2af",
--   yellow_dark = "#f5c77b",
--
--   peach = "#fab387",
--   peach_dark = "#f5a87b",
--
--   maroon = "#eba0ac",
--   maroon_dark = "#c97b84",
--
--   red = "#f38ba8",
--   red_dark = "#c97b84",
--
--   mauve = "#cba6f7",
--   mauve_dark = "#a17be3",
--
--   pink = "#f5c2e7",
--
--   flamingo = "#f2cdcd",
--
--   rosewater = "#f5e0dc",
--
--   cyan = "#bee4ed",
-- }
--
-- g.colors = colors
