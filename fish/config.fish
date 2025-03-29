if status is-interactive
  # # mise
  # mise activate fish | source

  # #devbox
  # eval "$(devbox global shellenv)"

  #zoxide
  zoxide init --cmd cd fish | source


  # Abbreviations
  abbr -a c clear
  abbr -a v nvim 
  abbr -a vim nvim 
  abbr -a ls lla --icons -l

  #Starship
  starship init fish | source
  export STARSHIP_CONFIG=/root/dotfiles/starship/starship.toml

  # golang
  # source ~/.asdf/plugins/golang/set-env.fish
  fish_add_path $GOBIN 


end


