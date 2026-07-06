local wezterm = require("wezterm")
local c = wezterm.config_builder()

local rosepine = wezterm.plugin.require("https://github.com/neapsix/wezterm").main
local cyberdream = require("cyberdream")

local catppuccin = {
	color_scheme = "Catppuccin Mocha",
	color_schemes = {
		["Catppuccin Mocha"] = {
			foreground = "#eee9fc",
			background = "#000000",
			cursor_bg = "#573d7a",
			cursor_border = "#eee9fc",
			cursor_fg = "#573d7a",
			selection_bg = "#3f3951",
			selection_fg = "#eee9fc",

			ansi = { "#282433", "#e965a5", "#b1f2a7", "#ebde76", "#b1baf4", "#e192ef", "#b3f4f3", "#eee9fc" },
			brights = { "#3f3951", "#e965a5", "#b1f2a7", "#ebde76", "#b1baf4", "#e192ef", "#b3f4f3", "#eee9fc" },
		},
	},
}

local cyberdream = {
	-- cyberdream theme for wezterm
	foreground = "#ffffff",
	background = "#16181a",

	cursor_bg = "#ffffff",
	cursor_fg = "#16181a",
	cursor_border = "#ffffff",

	selection_fg = "#ffffff",
	selection_bg = "#3c4048",

	scrollbar_thumb = "#16181a",
	split = "#16181a",

	ansi = { "#16181a", "#ff6e5e", "#5eff6c", "#f1ff5e", "#5ea1ff", "#bd5eff", "#5ef1ff", "#ffffff" },
	brights = { "#3c4048", "#ff6e5e", "#5eff6c", "#f1ff5e", "#5ea1ff", "#bd5eff", "#5ef1ff", "#ffffff" },
	indexed = { [16] = "#ffbd5e", [17] = "#ff6e5e" },
}

c.colors = require("vector")

c.font = wezterm.font("FiraCode Nerd Font")
c.window_decorations = "TITLE | RESIZE"
c.macos_window_background_blur = 20
c.window_background_opacity = 0.9
c.font_size = 11.0
-- dpi = 192.0,
c.leader = { key = "a", mods = "CTRL" }
c.keys = {
	{ key = "a", mods = "LEADER|CTRL", action = wezterm.action({ SendString = "\x01" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{
		key = "_",
		mods = "LEADER",
		action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
	},
	{ key = "+", mods = "SUPER", action = wezterm.action.IncreaseFontSize },
	{ key = "s", mods = "LEADER", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "v", mods = "LEADER", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = "o", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "c", mods = "LEADER", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
	{ key = "j", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
	{ key = "k", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
	{ key = "l", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
	{ key = "H", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }) },
	{ key = "J", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }) },
	{ key = "K", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }) },
	{ key = "L", mods = "LEADER|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }) },
	{ key = "1", mods = "LEADER", action = wezterm.action({ ActivateTab = 0 }) },
	{ key = "2", mods = "LEADER", action = wezterm.action({ ActivateTab = 1 }) },
	{ key = "3", mods = "LEADER", action = wezterm.action({ ActivateTab = 2 }) },
	{ key = "4", mods = "LEADER", action = wezterm.action({ ActivateTab = 3 }) },
	{ key = "5", mods = "LEADER", action = wezterm.action({ ActivateTab = 4 }) },
	{ key = "6", mods = "LEADER", action = wezterm.action({ ActivateTab = 5 }) },
	{ key = "7", mods = "LEADER", action = wezterm.action({ ActivateTab = 6 }) },
	{ key = "8", mods = "LEADER", action = wezterm.action({ ActivateTab = 7 }) },
	{ key = "9", mods = "LEADER", action = wezterm.action({ ActivateTab = 8 }) },
	{ key = "&", mods = "LEADER|SHIFT", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
	{ key = "d", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
	{ key = "x", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
}

c.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(c, {

	direction_keys = {
		move = { "h", "j", "k", "l" },
	},
	modifiers = {
		move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
		resize = "CTRL|SHIFT", -- modifier to use for pane resize, e.g. META+h to resize to the left
	},
})

wezterm.plugin
	.require("https://github.com/yriveiro/wezterm-tabs")
	.apply_to_config(c, { tabs = { tab_bar_at_bottom = true } })

return c
