local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder and wezterm.config_builder() or {}

wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.window_decorations = "RESIZE"
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font_with_fallback({
  "VictorMono NF",
  "DejaVu Sans Mono",
  "Twitter Color Emoji",
})
config.hide_tab_bar_if_only_one_tab = true
config.default_cursor_style = "BlinkingUnderline"
config.colors = { cursor_border = "#AAAA00" }

local function configure_presentation_mode(font_size)
  local presentation_font_size = font_size * 2.4

  wezterm.on("presentation-mode", function(window)
    local overrides = window:get_config_overrides() or {}
    overrides.font_size = presentation_font_size
    window:set_config_overrides(overrides)
  end)

  wezterm.on("normal-mode", function(window)
    local overrides = window:get_config_overrides() or {}
    overrides.font_size = nil
    window:set_config_overrides(overrides)
  end)
end

wezterm.on("augment-command-palette", function()
  return {
    { brief = "Presentation mode", action = wezterm.action.EmitEvent("presentation-mode") },
    { brief = "Normal mode", action = wezterm.action.EmitEvent("normal-mode") },
  }
end)

config.keys = {
  { key = "F11", action = wezterm.action.ToggleFullScreen },
  { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
  { key = "t", mods = "SUPER", action = wezterm.action.DisableDefaultAssignment },
  { key = "n", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
  { key = "n", mods = "SUPER", action = wezterm.action.DisableDefaultAssignment },
  { key = "t", mods = "SHIFT|ALT|CMD|CTRL", action = wezterm.action.DisableDefaultAssignment },
}

return function(profile)
  profile = profile or {}
  config.font_size = profile.font_size or 16
  config.default_domain = profile.default_domain
  config.default_prog = profile.default_prog or { "zellij" }

  -- Panes get back the library and EGL driver paths that the host-gpu wrapper replaced.
  local host_egl_vendor_dirs = os.getenv("VTR_HOST_EGL_VENDOR_DIRS")
  if host_egl_vendor_dirs then
    config.set_environment_variables = {
      __EGL_VENDOR_LIBRARY_DIRS = host_egl_vendor_dirs,
      LD_LIBRARY_PATH = os.getenv("VTR_HOST_LD_LIBRARY_PATH"),
    }
  end

  local isolated_launcher = os.getenv("VTR_NIX_WEZTERM_LAUNCHER")
  local isolated_profile = os.getenv("VTR_NIX_WEZTERM_PROFILE")
  if isolated_launcher and isolated_profile then
    config.default_prog = { isolated_launcher, isolated_profile, "-c", "exec zellij" }
  end

  configure_presentation_mode(config.font_size)
  return config
end
