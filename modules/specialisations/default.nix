{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./gaming.nix
  ];
  environment.sessionVariables = lib.mkIf (config.specialisation != {}) {
    SPECIALISATION = "none";
  };
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "switch-spec" ''
      if [ $# -ne 1 ]; then
        echo "Usage: switch-spec <specialisation>"
        exit 1
      fi

      sudo /nix/var/nix/profiles/system/specialisation/$1/bin/switch-to-configuration switch
    '')
  ];
}
