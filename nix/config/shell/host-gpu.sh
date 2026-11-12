[[ -e /run/opengl-driver ]] && exec "$@"

# Nix GL clients only search /run/opengl-driver. Elsewhere borrow the host's NVIDIA
# userspace driver, patched to resolve its dependencies from Nix, or fall back to Mesa.
# GLX vendors are looked up by name, so only these driver directories join LD_LIBRARY_PATH.
export VTR_HOST_EGL_VENDOR_DIRS=${__EGL_VENDOR_LIBRARY_DIRS:-/etc/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d}
export VTR_HOST_LD_LIBRARY_PATH=${LD_LIBRARY_PATH-}

nvidia_driver() {
  local version host_lib host_dir driver tmp lib

  [[ -r /proc/driver/nvidia/version && -x /sbin/ldconfig ]] || return 0
  version=$(sed -nE 's/.*Kernel Module +([0-9.]+).*/\1/p' /proc/driver/nvidia/version)
  host_lib=$(/sbin/ldconfig -p | sed -nE '/^\s*libEGL_nvidia\.so\.0 /{s/.* => //p;q}')
  [[ -n "$version" && -n "$host_lib" ]] || return 0

  driver=${XDG_CACHE_HOME:-$HOME/.cache}/vtr/host-gpu/nvidia-$version-$cache_key
  if [[ ! -d "$driver" ]]; then
    host_dir=$(dirname -- "$(readlink -f -- "$host_lib")")
    mkdir -p -- "${driver%/*}"
    tmp=$(mktemp -d -- "$driver.XXXXXX")
    for lib in libEGL_nvidia.so.0 libGLX_nvidia.so.0 \
      libnvidia-{allocator,eglcore,glcore,glsi,gpucomp,tls}.so."$version" \
      libnvidia-egl-{gbm,wayland,xcb,xlib}.so.1; do
      [[ -e "$host_dir/$lib" ]] || continue
      install -m 755 -- "$host_dir/$lib" "$tmp/$lib"
      patchelf --set-rpath "\$ORIGIN:$nix_runpath" "$tmp/$lib"
    done
    printf '{"file_format_version":"1.0.0","ICD":{"library_path":"%s/libEGL_nvidia.so.0"}}\n' \
      "$driver" >"$tmp/10_nvidia.json"
    mv -T -- "$tmp" "$driver" || { [[ -d "$driver" ]] && rm -rf -- "$tmp"; }
  fi
  printf '%s\n' "$driver"
}

driver=$(nvidia_driver)
export __EGL_VENDOR_LIBRARY_DIRS=${driver:-$mesa_vendor_dir}
export LD_LIBRARY_PATH=${driver:-$mesa_glx_dir}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
exec "$@"
