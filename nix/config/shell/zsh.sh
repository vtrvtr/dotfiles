tw() {
  local target
  target=$(tv workspaces --inline) || return
  [[ -n "$target" ]] && builtin cd -- "$target" || return
}

f() {
  local target
  target=$(tv files) || return
  [[ -z "$target" ]] && return
  [[ -d "$target" ]] || target=$(dirname -- "$target")
  builtin cd -- "$target" || return
}
