{
  inputs,
  lib,
  pkgs,
  withHostGpu,
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
    python3Packages.debugpy
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

  graphicalPackages = [ (withHostGpu pkgs.neovide [ "neovide" ]) ];

  # Only the wild entry points: the package also ships an ld wrapper and propagates glibc's
  # tools, which would shadow the host's ld, ldd and friends. Projects opt in per config.toml.
  wildEntryPoints = pkgs.runCommand "wild-bin" { } ''
    mkdir -p "$out/bin"
    ln -s ${pkgs.wild}/bin/wild ${pkgs.wild}/bin/ld.wild "$out/bin/"
  '';

  linuxPackages = with pkgs; [
    oxker
    simplescreenrecorder
    wildEntryPoints
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
