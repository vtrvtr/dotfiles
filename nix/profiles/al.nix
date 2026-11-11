{ ... }:
{
  home = {
    homeDirectory = "/home/users/vitorh";
    sessionVariables.VTR_HOME_PROFILE = "al";
  };

  programs.bash.initExtra = builtins.readFile ../config/shell/al-site.sh;

  programs.atuin.settings.sync_frequency = "10m";
}
