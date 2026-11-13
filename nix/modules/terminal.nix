{
  config,
  lib,
  pkgs,
  withHostGpu,
  ...
}:
let
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

  zellijWithTerminalLibraries = pkgs.symlinkJoin {
    name = "${pkgs.zellij.name}-terminal";
    paths = [ pkgs.zellij ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/zellij" \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath (
            with pkgs;
            [
              fontconfig
              freetype
              libglvnd
              libX11
              libXcursor
              libXi
              libxkbcommon
              libXrandr
            ]
          )
        }
    '';
    inherit (pkgs.zellij) meta version;
  };
in
{
  programs = {
    zellij = {
      enable = true;
      package = (withHostGpu zellijWithTerminalLibraries [ "zellij" ]) // {
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
    "zellij/config.kdl".source = ../../zellij/config.kdl;
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
