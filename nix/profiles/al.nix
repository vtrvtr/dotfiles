{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  watchmanWithHostNss = pkgs.writeShellApplication {
    name = "watchman";
    text = ''
      uid=$(id -u)
      gid=$(id -g)
      nss_dir="''${XDG_RUNTIME_DIR:-$HOME/.cache}/watchman-nss/$uid"
      passwd_file="$nss_dir/passwd"
      group_file="$nss_dir/group"

      install -d -m 700 "$nss_dir"
      {
        ${pkgs.coreutils}/bin/cat /etc/passwd
        /usr/bin/getent passwd "$uid"
      } > "$passwd_file.tmp.$$"
      {
        ${pkgs.coreutils}/bin/cat /etc/group
        /usr/bin/getent group "$gid"
      } > "$group_file.tmp.$$"
      ${pkgs.coreutils}/bin/mv "$passwd_file.tmp.$$" "$passwd_file"
      ${pkgs.coreutils}/bin/mv "$group_file.tmp.$$" "$group_file"
      ${pkgs.coreutils}/bin/chmod 600 "$passwd_file" "$group_file"

      export NSS_WRAPPER_PASSWD="$passwd_file"
      export NSS_WRAPPER_GROUP="$group_file"
      export LD_PRELOAD="${pkgs.nss_wrapper}/lib/libnss_wrapper.so"
      exec ${pkgs.watchman}/bin/watchman "$@"
    '';
  };
in
{
  home = {
    homeDirectory = "/home/users/vitorh";
    sessionVariables.VTR_HOME_PROFILE = "al";
    sessionPath = [
      "${watchmanWithHostNss}/bin"
      "$HOME/.local/share/JetBrains/Toolbox/scripts"
    ];
    # Login shells keep the studio profile, which only sources ~/.bashrc.
    file.".bash_profile".enable = false;
  };

  vtr.migration.dotterTargets = lib.remove ".bash_profile" options.vtr.migration.dotterTargets.default;

  programs.bash = {
    # rez environments and containers run bash by name, and Nix's bash cannot load their glibc.
    package = null;
    bashrcExtra = ''. "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"'';
    initExtra =
      builtins.readFile ../config/shell/al-site.sh + builtins.readFile ../config/shell/drop-devbox.sh;
  };

  programs.atuin.settings.sync_frequency = "10m";
}
