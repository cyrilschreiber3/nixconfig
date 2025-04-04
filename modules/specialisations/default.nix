{
  config,
  lib,
  ...
}: {
  imports = [
    ./gaming.nix
  ];
  environment.sessionVariables = lib.mkIf (config.specialisation != {}) {
    SPECIALISATION = "NONE";
  };
}
