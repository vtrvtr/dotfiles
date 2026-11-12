{ ... }:
{
  imports = [
    ./container.nix
    ./host-gpu.nix
    ./jujutsu.nix
    ./migration.nix
    ./packages.nix
    ./shells.nix
    ./terminal.nix
    ./wezterm.nix
  ];
}
