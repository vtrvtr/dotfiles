{
  description = "Vitor's reproducible Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin-x64.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    television.url = "github:alexpasmantier/television";
    jj-ryu.url = "github:HaukeSchnau/jj-ryu/nix-flake";
    claude-code.url = "github:sadjow/claude-code-nix";
    pi.url = "github:earendil-works/pi";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        if system == "x86_64-darwin" then
          inputs.nixpkgs-darwin-x64.legacyPackages.${system}
        else
          nixpkgs.legacyPackages.${system};
    in
    {
      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShellNoCC {
          packages = [
            inputs.home-manager.packages.${system}.default
            (pkgsFor system).nixfmt-tree
          ];
        };
      });

      homeModules = {
        default = ./nix/modules;
        packages = ./nix/modules/packages.nix;
      };
    };
}
