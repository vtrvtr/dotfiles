{ lib, pkgs, ... }:
{
  programs.bash.initExtra = lib.mkBefore (builtins.readFile ../config/shell/ld-preload-guard.sh);

  home.packages = [
    (pkgs.writeShellApplication {
      name = "with-preload";
      text = builtins.readFile ../config/shell/with-preload.sh;
    })
  ];
}
