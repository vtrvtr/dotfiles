-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

-- This table will hold the configuration.

local config = {}

-- In newer versions of wezterm, use the config_builder which will

-- help provide clearer error messages

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

wezterm.on("gui-startup", function()
	local _, _, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- For example, changing the color scheme:

config.window_decorations = "RESIZE"
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("Monaspace Radon")
if wezterm.hostname() == "trpc" then
	config.default_domain = "WSL:Debian3"
	config.font_size = 12
	if wezterm.target_triplet == "x86_64-unknown-linux-gnu" then
		config.default_prog = { "fish" }
	end
else
	config.font_size = 16
end
main_font = "VictorMono NF"
config.font = wezterm.font_with_fallback({
	main_font,
	"OpenDyslexicAlt Nerd Font",
})
-- config.font = wezterm.font("VeraMono")
config.hide_tab_bar_if_only_one_tab = true
config.default_cursor_style = "BlinkingUnderline"
config.colors = {
	cursor_border = "#AAAA00",
}
config.keys = {
	{
		key = "F11",
		action = wezterm.action.ToggleFullScreen,
	},
}

-- and finally, return the configuration to wezterm

return config
