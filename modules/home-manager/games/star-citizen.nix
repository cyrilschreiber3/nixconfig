# ? For more info: https://github.com/starcitizen-lug/lug-helper and https://github.com/LovingMelody/nix-citizen
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.starCitizenConfig;
in {
  options.starCitizenConfig = {
    enable = lib.mkEnableOption "Enable Star Citizen module";
    installPackage = lib.mkEnableOption "Install Star Citizen package";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.starCitizen;
      description = "The Star Citizen package to install.";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf cfg.enable [
      pkgs.wineWow64Packages.stableFull
      inputs.nix-citizen.packages.${pkgs.system}.lug-helper
      (lib.mkIf cfg.installPackage cfg.package)
    ];
  };
}
