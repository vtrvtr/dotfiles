local configure = dofile("__VTR_WEZTERM_BASE__")
return configure({
  default_domain = "WSL:Debian3",
  default_prog = { "fish" },
  font_size = 12,
})
