{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.themes;

  # isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  colorHelpers = rec {
    # Internal helper: Convert 2-char hex string (e.g., "FF") to int (255)
    hexToDec = hexString: let
      upperHex = lib.stringToCharacters (lib.toUpper hexString);
      hexValues = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
      };
      highDigit = builtins.elemAt upperHex 0;
      lowDigit = builtins.elemAt upperHex 1;
    in
      (hexValues.${highDigit} * 16) + hexValues.${lowDigit};

    # Remove '#' prefix from hex color
    hexWithoutHash = hex: lib.removePrefix "#" hex;

    # Convert hex to RGB values (0-255)
    hexToRgb = hex: let
      cleanHex = hexWithoutHash hex;
      r = hexToDec (lib.substring 0 2 cleanHex);
      g = hexToDec (lib.substring 2 2 cleanHex);
      b = hexToDec (lib.substring 4 2 cleanHex);
    in {inherit r g b;};

    # Convert hex to RGB string format "r,g,b"
    hexToRgbString = hex: let
      rgb = hexToRgb hex;
    in "${toString rgb.r},${toString rgb.g},${toString rgb.b}";

    # Convert hex to RGBA string format "r,g,b,a"
    hexToRgbaString = hex: alpha: "${hexToRgbString hex},${toString alpha}";

    # Add alpha to hex color
    hexWithAlpha = hex: alpha: let
      cleanHex = hexWithoutHash hex;
      alphaHex = lib.toHexString (builtins.floor (alpha * 255));
      paddedAlpha =
        if lib.stringLength alphaHex == 1
        then "0${alphaHex}"
        else alphaHex;
    in "#${cleanHex}${paddedAlpha}";

    hexWithoutHashWithAlpha = hex: alpha: hexWithoutHash (hexWithAlpha hex alpha);

    # Create color palette with multiple formats
    enhanceColorPalette = palette:
      palette
      // {
        formats = lib.mapAttrs (name: hex: {
          hex = hex;
          hexNoHash = hexWithoutHash hex;
          hexWithAlpha = alpha: hexWithAlpha hex alpha;
          hexWithAlphaNoHash = alpha: hexWithoutHashWithAlpha hex alpha;
          rgb = hexToRgb hex;
          rgbString = "rgb(${hexToRgbString hex})";
          rgbStringNoPrefix = hexToRgbString hex;
          rgbaString = alpha: "rgba(${hexToRgbaString hex alpha})";
          rgbaStringNoPrefix = alpha: hexToRgbaString hex alpha;
        }) (lib.filterAttrs (n: v: lib.hasPrefix "color" n || n == "background" || n == "foreground") palette);
      };
  };

  colorPalettes = {
    tokyonight = colorHelpers.enhanceColorPalette {
      variant = "dark";
      background = "#1a1b26";
      foreground = "#c0caf5";
      color00 = "#15161e";
      color01 = "#f7768e";
      color02 = "#9ece6a";
      color03 = "#e0af68";
      color04 = "#7aa2f7";
      color05 = "#bb9af7";
      color06 = "#7dcfff";
      color07 = "#a9b1d6";
      color08 = "#414868";
      color09 = "#f7768e";
      color10 = "#9ece6a";
      color11 = "#e0af68";
      color12 = "#7aa2f7";
      color13 = "#bb9af7";
      color14 = "#7dcfff";
      color15 = "#c0caf5";
    };
  };

  availableThemes = {
    themes = {
      tokyonight = {
        prettyName = "Tokyo Night";
        gtk = {
          name = "Tokyonight-Dark-BL-LB";
          package = import ./tokyonight-gtk-theme.nix {inherit pkgs;};
        };
        plasma = {
          style = "Tokyo-Night";
          colorScheme = "TokyoNight";
          lookAndFeel = "com.github.Jeyy-Dev.Plasma.Tokyo.Night";
          package = import ./tokyonight-kde-theme.nix {inherit pkgs;};
          kwin = {
            library = "org.kde.kwin.aurorae";
            theme = "__aurorae__svg__TokyoNight";
          };
        };
        defaultIconTheme = "whitesur";
        defaultCursorTheme = "whitesur";
        defaultWallpaper = pkgs.copyPathToStore ./../assets/wallpaper.jpg;
        variant = "dark";
      };
    };
    iconThemes = lib.optionalAttrs isLinux {
      whitesur = {
        name = "WhiteSur-dark";
        package = pkgs.whitesur-icon-theme.override {
          alternativeIcons = true;
        };
      };
    };
    cursorThemes = lib.optionalAttrs isLinux {
      whitesur = {
        name = "WhiteSur-cursors";
        package = pkgs.whitesur-cursors;
      };
    };
  };

  selectedTheme =
    availableThemes.themes.${cfg.theme}
    // {
      iconTheme =
        if cfg.iconThemeOverride != null
        then availableThemes.iconThemes.${cfg.iconThemeOverride}
        else availableThemes.iconThemes.${availableThemes.themes.${cfg.theme}.defaultIconTheme} or null;
      cursorTheme =
        if cfg.cursorThemeOverride != null
        then availableThemes.cursorThemes.${cfg.cursorThemeOverride}
        else availableThemes.cursorThemes.${availableThemes.themes.${cfg.theme}.defaultCursorTheme} or null;
      wallpaper =
        if cfg.wallpaperOverride != null
        then pkgs.copyPathToStore cfg.wallpaperOverride
        else availableThemes.themes.${cfg.theme}.defaultWallpaper;
      colorPalette = colorPalettes.${cfg.theme};
    };
in {
  options = {
    global.theme = lib.mkOption {
      type = lib.types.attrs;
      description = "Global theme configuration";
      readOnly = true;
    };

    themes = {
      enable = lib.mkEnableOption "Enable themes configuration";
      theme = lib.mkOption {
        type = lib.types.enum ["tokyonight"];
        default = "tokyonight";
        description = "GTK theme to use";
      };
      cursorThemeOverride = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum ["whitesur"]);
        default = null;
        description = "Override cursor theme name";
      };
      iconThemeOverride = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum ["whitesur"]);
        default = null;
        description = "Override icon theme name";
      };
      wallpaperOverride = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Override wallpaper path";
      };
      themeGTK = lib.mkOption {
        type = lib.types.bool;
        default = isLinux;
        description = "Enable GTK theme configuration";
      };
      themeQt = lib.mkOption {
        type = lib.types.bool;
        default = isLinux;
        description = "Enable Qt theme configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    global.theme = selectedTheme;

    home.packages = with pkgs;
      lib.mkMerge [
        [
          sassc
        ]
        (lib.mkIf cfg.themeGTK [
          gtk-engine-murrine
          gnome-themes-extra
          dconf-editor
        ])
        (
          lib.mkIf (cfg.themeQt && selectedTheme.plasma.package != null)
          [selectedTheme.plasma.package]
        )
      ];

    gtk = lib.mkIf cfg.themeGTK {
      enable = true;
      theme = {
        name = selectedTheme.gtk.name;
        package = selectedTheme.gtk.package;
      };
      cursorTheme = {
        name = selectedTheme.cursorTheme.name;
        package = selectedTheme.cursorTheme.package;
      };
      iconTheme = {
        name = selectedTheme.iconTheme.name;
        package = selectedTheme.iconTheme.package;
      };
    };

    home.sessionVariables = {
      GTK_THEME = lib.mkIf cfg.themeGTK selectedTheme.gtk.name;
    };

    xdg.configFile = lib.mkMerge [
      (lib.mkIf cfg.themeGTK {
        "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
        "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
        "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
      })
    ];
  };
}
