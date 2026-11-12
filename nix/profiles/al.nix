{
  config,
  lib,
  options,
  ...
}:
{
  home = {
    homeDirectory = "/home/users/vitorh";
    sessionVariables.VTR_HOME_PROFILE = "al";
    sessionPath = [ "$HOME/.local/share/JetBrains/Toolbox/scripts" ];
    # Login shells keep the studio profile, which only sources ~/.bashrc.
    file.".bash_profile".enable = false;
  };

  vtr.migration.dotterTargets = lib.remove ".bash_profile" options.vtr.migration.dotterTargets.default;

  programs.bash = {
    bashrcExtra = ''. "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"'';
    initExtra = builtins.readFile ../config/shell/al-site.sh;
  };

  programs.atuin.settings.sync_frequency = "10m";
}
