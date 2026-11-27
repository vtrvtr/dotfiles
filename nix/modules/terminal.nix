{
  config,
  lib,
  pkgs,
  withHostGpu,
  ...
}:
let
  zellijNav = pkgs.callPackage ../packages/zellij-nav.nix { };

  withoutLock =
    name: source: lockFile:
    builtins.path {
      inherit name;
      path = source;
      filter = path: type: builtins.baseNameOf path != lockFile;
    };

  mutableLocks = {
    "nvim/nvim-pack-lock.json" = ../../nvim-pack/nvim-pack-lock.json;
  };
in
{
  programs = {
    zellij = {
      enable = true;
      # Nixpkgs puts the terminal libraries in Zellij's RUNPATH, so panes don't inherit them.
      package = (withHostGpu pkgs.zellij [ "zellij" ]) // {
        inherit (pkgs.zellij) version;
      };
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
      settings = { };
    };
  };

  xdg.configFile = {
    "gh-dash/config.yml".source = ../../gh-dash/config.yml;
    "nvim" = {
      source = withoutLock "nvim-config" ../../nvim-pack "nvim-pack-lock.json";
      recursive = true;
    };
    "television/config.toml".source = ../../television/config.toml;
    "television/default_channels.toml".source = ../../television/default_channels.toml;
    "television/cable".source = ../../television/cable;
    "yazi/yazi.toml".source = ../../yazi/yazi.toml;
    "zellij/config.kdl".source = pkgs.replaceVars ../../zellij/config.kdl {
      zellij_nav = "${zellijNav}/share/zellij/plugins/zellij_nav.wasm";
    };
    "zellij/layouts".source = ../../zellij/layouts;
    "zellij/zextract.kdl".source = ../../zellij/zextract.kdl;
  };

  home.activation.seedMutableNeovimLocks = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatMapAttrsStringSep "\n" (target: source: ''
      target=${lib.escapeShellArg "${config.xdg.configHome}/${target}"}
      if [[ ! -e "$target" ]]; then
        run ${pkgs.coreutils}/bin/mkdir -p -- "$(${pkgs.coreutils}/bin/dirname -- "$target")"
        run ${pkgs.coreutils}/bin/cp -- ${lib.escapeShellArg source} "$target"
        run ${pkgs.coreutils}/bin/chmod u+w -- "$target"
      fi
    '') mutableLocks
  );
}
