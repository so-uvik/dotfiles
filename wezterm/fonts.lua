local wezterm = require("wezterm")

local Fonts = {}

function Fonts.setup(config)
	config.font = wezterm.font_with_fallback({
		"JetBrainsMono Nerd Font",
		"Apple Color Emoji",
	})

	config.font_rules = {
		{
			intensity = "Bold",
			italic = true,
			font = wezterm.font_with_fallback({
				{
					family = "JetBrainsMono Nerd Font",
					weight = "Bold",
					italic = true,
				},
			}),
		},
		{
			intensity = "Normal",
			italic = true,
			font = wezterm.font_with_fallback({
				{
					family = "JetBrainsMono Nerd Font",
					italic = true,
				},
			}),
		},
		{
			intensity = "Half",
			italic = true,
			font = wezterm.font_with_fallback({
				{
					family = "JetBrainsMono Nerd Font",
					weight = "Light",
					italic = true,
				},
			}),
		},
	}
	config.font_size = 10.5
	config.underline_thickness = "200%"
	config.underline_position = "-3pt"
	config.line_height = 1
end

return Fonts
