{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.footConfig;
  colors = config.global.theme.colorPalette.formats;
in {
  options.footConfig = {
    enable = lib.mkEnableOption "Enable foot module";
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          shell = "${pkgs.zsh}/bin/zsh";
          font = "${config.global.fonts.monospace}:size=10";
        };
        scrollback.lines = 10000;
        colors-dark = {
          foreground = colors.foreground.hexNoHash;
          background = colors.background.hexNoHash;
          regular0 = colors.color00.hexNoHash;
          regular1 = colors.color01.hexNoHash;
          regular2 = colors.color02.hexNoHash;
          regular3 = colors.color03.hexNoHash;
          regular4 = colors.color04.hexNoHash;
          regular5 = colors.color05.hexNoHash;
          regular6 = colors.color06.hexNoHash;
          regular7 = colors.color07.hexNoHash;
          bright0 = colors.color08.hexNoHash;
          bright1 = colors.color09.hexNoHash;
          bright2 = colors.color10.hexNoHash;
          bright3 = colors.color11.hexNoHash;
          bright4 = colors.color12.hexNoHash;
          bright5 = colors.color13.hexNoHash;
          bright6 = colors.color14.hexNoHash;
          bright7 = colors.color15.hexNoHash;

          dim0 = "ff9e64";
          dim1 = "db4b4b";
        };
      };
    };
  };
}
