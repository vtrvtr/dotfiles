{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vtr.migration;
  targets = map (target: "${config.home.homeDirectory}/${target}") cfg.dotterTargets;
  targetList = lib.concatStringsSep " " (map lib.escapeShellArg targets);
  marker = "${config.xdg.stateHome}/home-manager/dotter-migrated";
in
{
  options.vtr.migration = {
    enable = lib.mkEnableOption "migration from Dotter-managed links";
    dotterTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        ".bash_profile"
        ".bashrc"
        ".profile"
        ".zprofile"
        ".zshenv"
        ".zshrc"
        ".config/atuin"
        ".config/fish/config.fish"
        ".config/gh-dash"
        ".config/jj/config.toml"
        ".config/nvim"
        ".config/starship.toml"
        ".config/television"
        ".config/yazi"
        ".config/zellij"
        ".wezterm.lua"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.backupDotterLinks = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      if [[ -e ${lib.escapeShellArg marker} ]]; then
        exit 0
      fi

      for target in ${targetList}; do
        if [[ -L "$target" ]]; then
          resolved=$(${pkgs.coreutils}/bin/readlink -f -- "$target")
          [[ "$resolved" == /nix/store/* ]] && continue
        elif [[ ! -e "$target" ]]; then
          continue
        fi

        backup="$target.dotter-backup"
        if [[ -e "$backup" || -L "$backup" ]]; then
          echo "Cannot migrate $target: $backup already exists" >&2
          exit 1
        fi
      done

      for target in ${targetList}; do
        if [[ -L "$target" ]]; then
          resolved=$(${pkgs.coreutils}/bin/readlink -f -- "$target")
          [[ "$resolved" == /nix/store/* ]] && continue
        elif [[ ! -e "$target" ]]; then
          continue
        fi
        run ${pkgs.coreutils}/bin/mv -- "$target" "$target.dotter-backup"
      done

      run ${pkgs.coreutils}/bin/mkdir -p -- ${lib.escapeShellArg (builtins.dirOf marker)}
      run ${pkgs.coreutils}/bin/touch -- ${lib.escapeShellArg marker}
    '';
  };
}
