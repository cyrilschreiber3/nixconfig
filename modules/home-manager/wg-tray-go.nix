{
  config,
  inputs,
  lib,
  # pkgs,
  osConfig,
  ...
}: let
  cfg = config.wgTrayGoConfig;
in {
  imports = [
    inputs.wg-tray-go.homeManagerModules.default
  ];

  options.wgTrayGoConfig = {
    enable = lib.mkEnableOption "Enable WG Tray Go module";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.wg-tray-go.overlays.default
    ];

    programs.wg-tray-go = {
      enable = true;
      settings = osConfig.wireguardTunnels.wgTrayGoConfig;
    };

    # xdg.configFile = lib.mkIf pkgs.stdenv.isLinux {
    #   "autostart/wg-tray-go.desktop".source = "${pkgs.wg-tray-go}/share/applications/wg-tray-go.desktop";
    # };
  };
}
