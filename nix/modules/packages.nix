{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  packageFrom = input: fallback: lib.attrByPath [ system "default" ] fallback input.packages;

  commonPackages = with pkgs; [
    ast-grep
    atuin
    basedpyright
    bat
    binsider
    bottom
    brush
    cargo-nextest
    cargo-workspaces
    chafa
    difftastic
    dotter
    dust
    erdtree
    fd
    fzf
    gh
    gh-dash
    hyperfine
    jless
    jujutsu
    jjui
    just
    lla
    lldb
    mermaid-cli
    neovim
    nodejs_24
    pik
    pipx
    presenterm
    ripgrep
    ruff
    rustup
    starship
    tree-sitter
    uv
    watchman
    watchexec
    yazi
    zellij
    zoxide
  ];

  graphicalPackages = with pkgs; [
    neovide
    wezterm
  ];

  linuxPackages = with pkgs; [
    oxker
    simplescreenrecorder
    wild
  ];
in
{
  nixpkgs.config.allowUnfree = true;

  home.packages =
    commonPackages
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux linuxPackages
    ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin || system == "aarch64-darwin") [
      (packageFrom inputs.claude-code pkgs.claude-code)
    ]
    ++ graphicalPackages
    ++ [
      (packageFrom inputs.jj-ryu pkgs.jj-ryu)
      (packageFrom inputs.pi pkgs.pi)
      (packageFrom inputs.television pkgs.television)
    ];
}
