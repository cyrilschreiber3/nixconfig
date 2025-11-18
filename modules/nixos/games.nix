{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.gamesConfig;
in {
  options.gamesConfig = {
    enable = lib.mkEnableOption "Enable gaming related settings and packages";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
    };

    programs.steam = {
      enable = true;
      package = pkgs.stable.steam;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-ng
      lutris
      bottles
    ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/cyril/.steam/root/compatibilitytools.d";
    };
  };
}
