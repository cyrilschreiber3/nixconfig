{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.missionChiefConfig;
in {
  options.missionChiefConfig = {
    enable = lib.mkEnableOption "Enable Mission Chief module";
  };
  config = lib.mkIf cfg.enable {
    xdg.desktopEntries = {
      mission-chief = {
        name = "Opérateur 112";
        genericName = "Video Game";
        icon = "${pkgs.copyPathToStore ./../../../modules/assets/mission-chief-icon.jpg}";
        exec = "chromium --app=https://www.operateur112.fr/ --disable-glsl-translator --start-maximized";
        terminal = false;
        categories = ["Game"];
      };
    };
  };
}
