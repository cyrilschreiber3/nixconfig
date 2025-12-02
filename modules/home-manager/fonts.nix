{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fontsConfig;
in {
  options = {
    global.fonts = lib.mkOption {
      type = lib.types.attrs;
      description = "Global fonts configuration";
      readOnly = true;
    };

    fontsConfig = {
      enable = lib.mkEnableOption "Enable font configuration using fontconfig";

      defaultFonts = {
        serif = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "Default serif font";
          default = ["DejaVu Serif"];
        };

        sansSerif = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "Default sans-serif font";
          default = ["DejaVu Sans"];
        };

        monospace = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "Default monospace font";
          default = ["MesloLGS Nerd Font"];
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    global.fonts = {
      serif = builtins.elemAt cfg.defaultFonts.serif 0;
      sansSerif = builtins.elemAt cfg.defaultFonts.sansSerif 0;
      monospace = builtins.elemAt cfg.defaultFonts.monospace 0;
      list = {
        serif = cfg.defaultFonts.serif;
        sansSerif = cfg.defaultFonts.sansSerif;
        monospace = cfg.defaultFonts.monospace;
      };
    };

    home.packages = with pkgs; [
      dejavu_fonts
      nerd-fonts.meslo-lg
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = cfg.defaultFonts.serif;
        sansSerif = cfg.defaultFonts.sansSerif;
        monospace = cfg.defaultFonts.monospace;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        monospace-font-name = "${config.global.fonts.monospace} 10";
        font-name = "${config.global.fonts.sansSerif} 10";
      };
      "org/cinnamon/desktop/interface" = {
        font-name = "${config.global.fonts.sansSerif} 10";
      };
    };
  };
}
