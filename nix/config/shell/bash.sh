tw() {
  local target
  target=$(tv workspaces --inline) || return
  target=${target#$'\e[?u\e[c'}
  [[ -n "$target" ]] && builtin cd -- "$target" || return
}

f() {
  local target
  target=$(tv files) || return
  target=${target#$'\e[?u\e[c'}
  [[ -z "$target" ]] && return
  [[ -d "$target" ]] || target=$(dirname -- "$target")
  builtin cd -- "$target" || return
}
