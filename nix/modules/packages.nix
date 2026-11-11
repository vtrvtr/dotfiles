{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  packageFrom = input: input.packages.${system}.default;

  commonPackages = with pkgs; [
    ast-grep
    atuin
    basedpyright
    bat
    binsider
    bottom
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
    jjui
    just
    lla
    lldb
    mermaid-cli
    neovim
    nodejs_24
    oxker
    pik
    pipx
    presenterm
    ripgrep
    ruff
    rustup
    starship
    tree-sitter
    uv
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
    simplescreenrecorder
  ];
in
{
  nixpkgs.config.allowUnfree = true;

  home.packages =
    commonPackages
    ++ lib.optionals pkgs.stdenv.isLinux linuxPackages
    ++ lib.optionals (!pkgs.stdenv.isDarwin || system == "aarch64-darwin") [
      (packageFrom inputs.claude-code)
    ]
    ++ graphicalPackages
    ++ [
      (packageFrom inputs.jj-ryu)
      (packageFrom inputs.pi)
      (packageFrom inputs.television)
    ];
}
