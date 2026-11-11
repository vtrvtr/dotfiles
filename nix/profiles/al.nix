{ ... }:
{
  home = {
    homeDirectory = "/home/users/vitorh";
    sessionVariables.VTR_HOME_PROFILE = "al";
  };

  programs.bash.initExtra = builtins.readFile ../config/shell/al-site.sh;

  programs.atuin.settings = {
    db_path = "/fast/tools/atuin/history.db";
    key_path = "/fast/tools/atuin/.key";
    session_path = "/fast/tools/atuin/session";
    sync_address = "http://va1wse0062.van.animallogic.ca:8888";
    sync_frequency = "10m";
  };
}
