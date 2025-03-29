# vtr dotfiles

## Just do it 

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
