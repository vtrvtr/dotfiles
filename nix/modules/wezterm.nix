{
  config,
  lib,
  pkgs,
  withHostGpu,
  ...
}:
let
  cfg = config.vtr.wezterm;
  source = builtins.readFile cfg.profile;
  rendered =
    builtins.replaceStrings [ "__VTR_WEZTERM_BASE__" ] [ "${../config/wezterm/base.lua}" ]
      source;
in
{
  options.vtr.wezterm.profile = lib.mkOption {
    type = lib.types.path;
    default = ../config/wezterm/generic.lua;
  };

  config.programs.wezterm = {
    enable = true;
    package = withHostGpu pkgs.wezterm [
      "wezterm"
      "wezterm-gui"
    ];
    extraConfig = rendered;
  };
}
