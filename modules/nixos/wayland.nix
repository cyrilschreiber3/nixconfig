{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.waylandConfig;
in {
  options.waylandConfig = {
    enable = lib.mkEnableOption "Enable Wayland module";
    # displayManager = lib.mkOption {
    #   type = lib.types.enum ["lightdm"];
    #   default = "lightdm";
    #   description = "Display manager to use";
    # };
    desktopManager = lib.mkOption {
      type = lib.types.enum ["hyprland"];
      default = "hyprland";
      description = "Desktop manager to use";
    };
    theme = lib.mkOption {
      type = lib.types.enum ["tokyonight"];
      default = "tokyonight";
      description = "General theme name";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      colord
    ];

    programs.hyprland = {
      enable = cfg.desktopManager == "hyprland";
      withUWSM = true;
      xwayland.enable = true;
    };
  };
}
