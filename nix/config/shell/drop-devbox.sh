# Devbox is gone, but sessions started under it still pass its variables and PATH entries down.
for name in ${!DEVBOX_@} ${!__DEVBOX@}; do
  unset "$name"
done
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vi devbox | awk 'NF && !seen[$0]++' | paste -sd: -)
