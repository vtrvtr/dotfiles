# vtr dotfiles

## Nix flake

The Home Manager flake is an opt-in replacement for package and dotfile deployment. The existing Devbox and Dotter setup remains available.

Profiles:

| Profile | Target |
| --- | --- |
| `vitorh@generic-linux` | Portable x86_64 Linux |
| `vitorh@al` | Animal Logic Linux with internal Atuin storage |
| `vitorh@trpc` | trpc Linux/WSL with its WezTerm defaults |
| `vitorh@macos` | Apple Silicon macOS |
| `vitorh@macos-intel` | Intel macOS |

List and build profiles without changing the home directory:

```bash
./scripts/nix-build.sh --list
./scripts/nix-build.sh al
```

Start an isolated profile shell without changing normal home configuration:

```bash
./scripts/nix-shell.sh al
```

This keeps `HOME` unchanged so `~/.al_env`, credentials, certificates, and project files remain available. It redirects XDG configuration, data, state, and cache into `~/.local/share/vtr-nix/<profile>/`. Set `VTR_NIX_ROOT` to use another state root. Removing that directory resets the isolated environment.

Activate a profile permanently with Home Manager only when desired:

```bash
./scripts/nix-switch.sh al
```

On the first activation, the profile moves conflicting Dotter links and shell files to adjacent `.dotter-backup` paths before Home Manager links its generation. It refuses to overwrite an existing backup. The legacy repo configuration is not deleted, so Dotter can be restored after moving the Home Manager links aside.

Change the profile name for another host. After the first activation, `home-manager` is installed in the managed profile:

```bash
home-manager --flake '.#vitorh@al' switch
```

`nix/hosts/` selects each target. `nix/profiles/` holds host behavior, `nix/modules/` holds shared Home Manager modules, and ordinary shell/Lua sources live under `nix/config/`. Home Manager deploys `nvim-pack/` as the default `~/.config/nvim` configuration.

Validate every profile with:

```bash
./scripts/nix-check.sh
```

Update pinned tools and validate the result with:

```bash
./scripts/nix-update.sh
```

Arguments after the profile or command are forwarded to Nix or Home Manager.

## Legacy setup

1. Run `install.sh` for bash.
2. Run `install.fish` for fish.

## Manual Install

1. `curl -fsSL https://get.jetify.com/devbox | bash` (or other shell)
  * Add to your rc file: `eval "$(devbox global shellenv --init-hook)"`. If bash. Others [here](https://www.jetify.com/docs/devbox/devbox_global/).
2. `devbox add dotter`
3. `dotter deploy`. This should be run from the repository root folder.
4. Incredibly, that's all.

---
`devbox` tries to install `nix` by itself. Depending on the platform, that won't be possible. [More info here](https://www.jetify.com/docs/devbox/installing_devbox/). [Determine Nix](htps://github.com/DeterminateSystems/nix-installer)] usually works

---
