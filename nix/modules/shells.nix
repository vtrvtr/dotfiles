{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  television = lib.attrByPath [ system "default" ] pkgs.television inputs.television.packages;
  tvInit =
    shell:
    pkgs.runCommand "television-init-${shell}" { nativeBuildInputs = [ television ]; } ''
      export HOME="$TMPDIR/home"
      export XDG_CONFIG_HOME="$HOME/.config"
      mkdir -p "$out" "$XDG_CONFIG_HOME/television"
      tv init ${shell} > "$out/init"
    '';

  aliases = {
    c = "clear";
    gha = "gh-dash";
    j = "jjui";
    l = "lla -s date -l";
    nw = "NVIM_APPNAME=nvim_windows nvim";
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
    wt = "watchexec -d 500ms -r --bell -N";
  };
in
{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = aliases // {
        reload = "exec bash";
      };
      initExtra = ''
        source ${tvInit "bash"}/init
        source ${../../bash/jj_gh_stack.sh}
        ${builtins.readFile ../config/shell/bash.sh}
        ${builtins.readFile ../config/shell/github-mcp.sh}
      '';
    };

    fish = {
      enable = true;
      shellAliases = aliases;
      shellAbbrs = {
        c = "clear";
        l = "lla --icons -l";
        v = "nvim";
        vim = "nvim";
      };
      interactiveShellInit = ''
        source ${tvInit "fish"}/init
        ${builtins.readFile ../config/shell/fish.fish}
      '';
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      shellAliases = aliases // {
        reload = "exec zsh";
      };
      initContent = lib.mkOrder 1200 ''
        source ${tvInit "zsh"}/init
        ${builtins.readFile ../config/shell/zsh.sh}
      '';
    };

    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = false;
        enter_accept = false;
        local_timeout = 5;
        network_connect_timeout = 5;
        network_timeout = 5;
        search_mode = "fulltext";
        show_help = true;
        show_preview = true;
        update_check = false;
        daemon = {
          enabled = false;
          sync_frequency = 3000;
        };
        sync.records = true;
      };
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings = builtins.fromTOML (builtins.readFile ../../starship/starship.toml);
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}
