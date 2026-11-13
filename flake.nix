{
  description = "Vitor's reproducible Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
      mkHome =
        {
          host,
          system,
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./nix/modules
            ./nix/hosts/${host}.nix
          ];
        };
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

      homeConfigurations = {
        "vitorh@generic-linux" = mkHome {
          host = "generic-linux";
          system = "x86_64-linux";
        };
        "vitorh@al" = mkHome {
          host = "al";
          system = "x86_64-linux";
        };
        "vitorh@trpc" = mkHome {
          host = "trpc";
          system = "x86_64-linux";
        };
        "vitorh@macos" = mkHome {
          host = "macos";
          system = "aarch64-darwin";
        };
      };

      homeModules = {
        default = ./nix/modules;
        packages = ./nix/modules/packages.nix;
      };
    };
}
