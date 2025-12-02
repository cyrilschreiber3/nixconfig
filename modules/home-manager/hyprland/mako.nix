{
  config,
  lib,
  ...
}: let
  cfg = config.makoConfig;

  themes = {
    tokyonight = {
      background = "#1a1b26";
      text = "#c0caf5";
      border = "#7aa2f7";
      progress = "#7aa2f7";
    };
  };

  currentTheme = themes.${cfg.theme};
in {
  options.makoConfig = {
    enable = lib.mkEnableOption "Enable mako notification daemon configuration";
    theme = lib.mkOption {
      type = lib.types.enum ["tokyonight"];
      default = "tokyonight";
      description = "Mako theme to use. Currently only 'tokyonight' is supported.";
    };
    font = lib.mkOption {
      type = lib.types.str;
      default = config.global.fonts.monospace;
      description = "Fonts to use for notifications.";
    };
  };

  # TODO: test norifications
  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;

      settings = {
        background-color = currentTheme.background;
        text-color = currentTheme.text;
        border-color = currentTheme.border;
        progress-color = currentTheme.progress;
        font = "${cfg.font} 10";

        width = 420;
        height = 110;
        padding = "10";
        margin = "10";
        border-size = 2;
        border-radius = 10;

        anchor = "top-right";
        layer = "overlay";

        default-timeout = 5000;
        ignore-timeout = false;
        max-visible = 5;
        sort = "-time";

        group-by = "app-name";

        actions = true;

        format = "<b>%s</b>\\n%b";
        markup = true;
      };
    };
  };
}
