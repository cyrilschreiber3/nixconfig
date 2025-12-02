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
    desktopManager = lib.mkOption {
      type = lib.types.enum ["hyprland" "plasma"];
      default = "hyprland";
      description = "Desktop manager to use";
    };
    displayManager = lib.mkOption {
      type = lib.types.enum ["autologin" "sddm"];
      default = "autologin";
      description = "Display manager to use";
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

    programs.hyprland = lib.mkIf (cfg.desktopManager == "hyprland") {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    services.displayManager.sddm = lib.mkIf (cfg.displayManager == "sddm") {
      enable = true;
      wayland.enable = true;
      settings.General.DisplayServer = "wayland";
    };

    services.desktopManager.plasma6 = lib.mkIf (cfg.desktopManager == "plasma") {
      enable = true;
    };

    services.getty.autologinUser = lib.mkIf (cfg.displayManager == "autologin") config.mainUser.userName;
  };
}
