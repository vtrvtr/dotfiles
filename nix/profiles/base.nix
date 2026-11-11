{ lib, ... }:
{
  home = {
    username = "vitorh";
    homeDirectory = lib.mkDefault "/home/vitorh";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
