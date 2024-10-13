local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = "NeverPrompt"

config.font_size = 16
config.line_height = 1.09
config.cell_width = 1
config.cursor_thickness = "2px"
config.freetype_load_target = "Normal"
config.freetype_load_flags = "DEFAULT"

config.font = wezterm.font_with_fallback({
	{ family = "Inconsolata" },
	{ family = "Symbols Nerd Font Mono", scale = 0.8 },
})

local colorscheme = "light"

if colorscheme == "dark" then
	config.font_rules = {
		{
			intensity = "Bold",
			font = wezterm.font("Inconsolata", { weight = "ExtraBold" }),
		},
	}
	config.colors = require("dark")
else
	config.colors = require("light")
end

return config
