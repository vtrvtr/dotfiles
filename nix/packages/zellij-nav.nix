{ lib, pkgsCross }:
let
  wasi = pkgsCross.wasm32-wasip1;
  root = ../../zellij/zellij-nav;
in
wasi.rustPlatform.buildRustPackage {
  pname = "zellij-nav";
  version = "0.1.0";

  src = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.unions [
      (root + "/Cargo.toml")
      (root + "/Cargo.lock")
      (root + "/src")
    ];
  };
  cargoLock.lockFile = root + "/Cargo.lock";

  # Match nixpkgs' Zellij plugins: use LLD's WASM linker for the WASI target.
  nativeBuildInputs = [ wasi.lld ];
  env.RUSTFLAGS = "-C linker=wasm-ld";

  doCheck = false; # The cross-built executable needs a WASI runtime.
  installPhase = ''
    runHook preInstall
    install -Dm644 target/wasm32-wasip1/release/zellij_nav.wasm "$out/share/zellij/plugins/zellij_nav.wasm"
    runHook postInstall
  '';
}
