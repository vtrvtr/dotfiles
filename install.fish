#!/usr/bin/env fish

# 1. Install devbox if it's not already installed.
if not type -q devbox
    echo "Installing devbox..."
    curl -fsSL https://get.jetify.com/devbox | bash
else
    echo "devbox is already installed."
end

# 1b. Ensure the devbox shellenv init hook is present in config.fish.
set fish_config "$HOME/.config/fish/config.fish"
set init_line 'eval (devbox global shellenv --init-hook)'

if test -f $fish_config
    if not grep -Fq "$init_line" $fish_config
        echo $init_line >> $fish_config
        echo "Added devbox shellenv init hook to $fish_config"
    else
        echo "devbox shellenv init hook already present in $fish_config"
    end
else
    echo "$fish_config not found. Creating it and adding init hook."
    echo $init_line > $fish_config
end

# Immediately load the devbox environment for the current session.
eval (devbox global shellenv --init-hook)

# 2. Add dotter via devbox if it's not already added.
if not type -q dotter
    echo "Adding dotter via devbox..."
    devbox add dotter
else
    echo "dotter is already added."
end

# 3. Deploy dotter configurations (should be run from the repository root).
echo "Deploying dotter configuration..."
dotter deploy

echo "All steps completed."

