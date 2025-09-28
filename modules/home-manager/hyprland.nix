{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hyprlandConfig;
in {
  options.hyprlandConfig = {
    enable = lib.mkEnableOption "Enable Hyprland module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprland
      waybar
      kdePackages.dolphin
      wofi
      kitty
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
    };

    xdg.configFile."hypr/hyprland.conf".source = "${pkgs.copyPathToStore ../dotfiles/hypr/hyprland.conf}";
  };
}
