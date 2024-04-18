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
config.font_size = 16
config.hide_tab_bar_if_only_one_tab = true
if os.getenv("NAME") == "DESKTOP-VS3635G" then
	config.default_domain = "WSL:Debian"
end
config.default_prog = { 'zellij', '-l', 'welcome' }
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
