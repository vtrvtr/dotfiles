{ lib, ... }:
{
  home = {
    username = "vitorh";
    homeDirectory = lib.mkDefault "/home/vitorh";
    stateVersion = "26.05";
    sessionVariables = {
      EDITOR = "nvim";
      GIT_EDITOR = "nvim";
      JJ_EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs.home-manager.enable = true;
  vtr.migration.enable = true;
}
