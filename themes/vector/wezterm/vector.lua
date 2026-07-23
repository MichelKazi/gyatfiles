-- vector color scheme for wezterm.
-- Usage in wezterm.lua:
--   local vector = require("vector")
--   config.color_schemes = { ["vector"] = vector }
--   config.color_scheme = "vector"
return {
  foreground = "#c8d8ea",
  background = "#0a0e17",
  cursor_bg = "#22d3ee",
  cursor_fg = "#0a0e17",
  cursor_border = "#22d3ee",
  selection_fg = "#eaf4ff",
  selection_bg = "#1c2e4a",
  scrollbar_thumb = "#2a3648",
  split = "#1a2332",
  ansi = { "#1a2332", "#ff5d73", "#34d399", "#f0b429", "#60a5fa", "#b18aff", "#22d3ee", "#c8d8ea" },
  brights = { "#3d4f6b", "#ff7a8c", "#6ee7b7", "#f7ce68", "#93c5fd", "#cfaaff", "#67e8f9", "#eaf4ff" },
  tab_bar = {
    background = "#05080f",
    active_tab = { bg_color = "#0d1a26", fg_color = "#22d3ee", intensity = "Bold" },
    inactive_tab = { bg_color = "#0a0e17", fg_color = "#3d4f6b" },
    inactive_tab_hover = { bg_color = "#0d1220", fg_color = "#5a7290" },
    new_tab = { bg_color = "#0a0e17", fg_color = "#3d4f6b" },
  },
}
