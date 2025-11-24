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
if wezterm.hostname() == "trpc" then
	config.default_domain = "WSL:Debian3"
	config.font_size = 12
	if wezterm.target_triplet == "x86_64-unknown-linux-gnu" then
		config.default_prog = { "fish" }
	end
else
	config.font_size = 16
end
config.font = wezterm.font_with_fallback({
	"VictorMono NF",
	"DejaVu Sans Mono",
	"Twitter Color Emoji",
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
	-- Turn off the default CMD-m Hide action, allowing CMD-m to
	-- be potentially recognized and handled by the tab
	{
		key = "t",
		mods = "SHIFT|ALT|CMD|CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},

	-- you may also use the "https://github.com/Xarvex/presentation.wez" mirror
	-- wezterm.plugin.require("https://gitlab.com/xarvex/presentation.wez").apply_to_config(config, {
	-- 	font_size_multiplier = 1.3, -- sets for both "presentation" and "presentation_full"
	-- 	presentation = {
	-- 		keybind = { key = "t", mods = "SHIFT|ALT" }, -- setting a keybind
	-- 	},
	-- 	presentation_full = {
	-- 		keybind = { key = "t", mods = "CTRL|ALT" }, -- setting a keybind
	-- 		font_weight = "Bold",
	-- 		font_size_multiplier = 2.4, -- overwrites "font_size_multiplier" for "presentation_full"
	-- 	},
	-- }),
}

-- and finally, return the configuration to wezterm

return config
