{ lib, pkgs, ... }:
let
  runpath = lib.makeLibraryPath (
    with pkgs;
    [
      libdrm
      libX11
      libXext
      libxcb
      wayland
    ]
  );

  mesaGlx = pkgs.linkFarm "mesa-glx" [
    {
      name = "libGLX_mesa.so.0";
      path = "${pkgs.mesa}/lib/libGLX_mesa.so.0";
    }
  ];

  script = builtins.readFile ../config/shell/host-gpu.sh;
  hostGpu = pkgs.writeShellApplication {
    name = "host-gpu";
    runtimeInputs = with pkgs; [
      coreutils
      gnused
      patchelf
    ];
    text = ''
      readonly nix_runpath=${runpath}
      readonly mesa_vendor_dir=${pkgs.mesa}/share/glvnd/egl_vendor.d
      readonly mesa_glx_dir=${mesaGlx}
      readonly cache_key=${builtins.substring 0 12 (builtins.hashString "sha256" (runpath + script))}
    ''
    + script;
  };

  withHostGpu =
    package: binaries:
    pkgs.symlinkJoin {
      name = "${package.name}-host-gpu";
      paths = [ package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = lib.concatMapStrings (binary: ''
        rm "$out/bin/${binary}"
        makeWrapper ${lib.getExe hostGpu} "$out/bin/${binary}" --add-flags ${package}/bin/${binary}
      '') binaries;
      inherit (package) meta;
    };
in
{
  _module.args.withHostGpu =
    if pkgs.stdenv.hostPlatform.isLinux then withHostGpu else package: _: package;
}
