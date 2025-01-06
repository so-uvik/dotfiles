local wezterm = require("wezterm")
local tab = require("tab")
local theme = require("theme")
local keys = require("keys")
local fonts = require("fonts")

local config = {
	enable_wayland = false,
	pane_focus_follows_mouse = false,
	default_cursor_style = "SteadyBar",
	warn_about_missing_glyphs = false,
	show_update_window = false,
	check_for_updates = false,
	window_decorations = "NONE",
	window_close_confirmation = "NeverPrompt",
	window_padding = {
		left = 5,
		right = 5,
		top = 5,
		bottom = 0,
	},
	initial_cols = 110,
	initial_rows = 25,
	inactive_pane_hsb = {
		saturation = 1.0,
		brightness = 0.90,
	},
	enable_scroll_bar = false,
	max_fps = 120,
	window_background_opacity = 0.8,
	unix_domains = {
		{
			name = "unix",
		},
	},
	hyperlink_rules = {
		{
			regex = "\\b\\w+://[\\w.-]+:[0-9]{2,15}\\S*\\b",
			format = "$0",
		},
		{
			regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
			format = "$0",
		},
		{
			regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
			format = "mailto:$0",
		},
		{
			regex = [[\bfile://\S*\b]],
			format = "$0",
		},
		{
			regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
			format = "$0",
		},
		{
			regex = [[\b[tT](\d+)\b]],
			format = "https://example.com/tasks/?t=$1",
		},
	},
}

-- config.unix_domains = {
-- 	{
-- 		name = "unix",
-- 	},
-- }
fonts.setup(config)
theme.setup(config)
keys.setup(config)
tab.setup(config)

return config
