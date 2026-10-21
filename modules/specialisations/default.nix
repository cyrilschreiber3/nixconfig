{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./vgpu.nix
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

      if [ "$1" == "default" ]; then
        SPECIALISATION="system"
      else
        SPECIALISATION="system/specialisation/$1"
      fi

      sudo /nix/var/nix/profiles/$SPECIALISATION/bin/switch-to-configuration switch
    '')
  ];
}
