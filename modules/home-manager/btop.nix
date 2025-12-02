{
  config,
  lib,
  ...
}: let
  cfg = config.btopConfig;
in {
  options.btopConfig = {
    enable = lib.mkEnableOption "Enable Btop module";
    colorTheme = lib.mkOption {
      type = lib.types.str;
      default = "tokyo-night";
      description = "The color theme to use for Btop";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = cfg.colorTheme;
      };
    };
  };
}
