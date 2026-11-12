set -l private_env $HOME/.config/vtr/private.env
set -q VTR_PRIVATE_CONFIG; and set private_env $VTR_PRIVATE_CONFIG
if test -r $private_env
  for line in (string match -rv '^\s*(#|$)' < $private_env)
    set -l pair (string split -m1 = -- (string replace -r '^export\s+' '' -- $line))
    set -gx $pair[1] (string trim -c '"\'' -- $pair[2])
  end
end
