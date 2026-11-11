function tw
  set target (tv workspaces --inline); or return
  test -n "$target"; and cd -- "$target"
end

function f
  set target (tv files); or return
  test -z "$target"; and return
  test -d "$target"; or set target (dirname -- "$target")
  cd -- "$target"
end
