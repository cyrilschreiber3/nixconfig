{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.remminaConfig;
in {
  options.remminaConfig = {
    enable = lib.mkEnableOption "Enable Remmina module";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      remmina
    ];

    xdg.configFile = {
      "autostart/remmina-applet.desktop".text = ""; # To disable autostart
      "remmina/remmina.pref".source = pkgs.copyPathToStore ./../dotfiles/remmina/remmina.pref;
    };
  };
}
