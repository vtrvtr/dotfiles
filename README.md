# vtr dotfiles

## Nix flake

A Home Manager flake deploys packages and dotfiles.

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

It starts bash or zsh, following `$SHELL`; set `VTR_NIX_SHELL=bash` or `VTR_NIX_SHELL=zsh` to choose.

Launch WezTerm with every new tab and pane entering that isolated profile:

```bash
./scripts/nix-wezterm.sh al
```

This keeps `HOME` unchanged so `~/.al_env`, credentials, certificates, and project files remain available. The child starts with a clean environment, loads system-wide shell configuration, and, for `al`, snapshots and loads the existing `.bashrc` plus AL environment. Parent Devbox state is not inherited; Devbox may initialize normally through the AL startup, after which the flake profile takes PATH precedence. XDG configuration, data, state, and cache live under `~/.local/share/vtr-nix/<profile>/`.

Set `VTR_NIX_ROOT` to use another state root. Removing that directory resets the isolated environment, including its snapshot of the host `.bashrc`.

Machine-local values are declared in `config/private-vars.conf`. They come from the host environment first, then `~/.config/vtr/private.env`, which overrides values that differ on a machine. Both the launcher and the Home Manager shells load that file, so on a new machine copy `config/private.env.example` there and set `JJ_USER` and `JJ_EMAIL` before the first shell. Keep it to plain `NAME="value"` lines so fish can read it. The launcher reports any required value still missing. Atuin defaults to `$XDG_DATA_HOME/atuin`; `VTR_ATUIN_HOME` and `VTR_ATUIN_SYNC_ADDRESS` are optional overrides.

Activate a profile permanently with Home Manager only when desired:

```bash
./scripts/nix-switch.sh al
```

On the first activation, the profile moves conflicting Dotter links and shell files to adjacent `.dotter-backup` paths before Home Manager links its generation. It refuses to overwrite an existing backup. Home Manager owns `~/.config/jj/config.toml`, so keep per-machine jj settings such as `[user]` or `[signing]` in `~/.config/jj/conf.d/*.toml`.

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
