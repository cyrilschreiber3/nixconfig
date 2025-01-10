{
  lib,
  pkgs,
  ...
}: {
  # Enable the X11 windowing system, lightdm display manager and cinnamon desktop environment.
  services.xserver = {
    enable = true;
    dpi = lib.mkDefault 104;
    videoDrivers = ["nvidia" "displaylink"];
    # displayManager.sessionCommands = ''$
    #   ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
    # '';
    displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        enable = true;
        theme = {
          name = "Tokyonight-Dark-BL-LB";
          package = "${pkgs.callPackage ./../../modules/themes/tokyonight-gtk-theme.nix {}}";
        };
        cursorTheme = {
          name = "WhiteSur-cursors";
          package = pkgs.whitesur-cursors;
        };
      };
      background = "${pkgs.copyPathToStore ./../../modules/assets/login-wallpaper.jpg}";
    };
    desktopManager = {
      cinnamon.enable = true;
      wallpaper.combineScreens = true;
      wallpaper.mode = "fill";
    };
  };

  services.autorandr = {
    enable = true;
    matchEdid = true;
    defaultTarget = "mobile";
    profiles = let
      fingerprints = {
        integrated = "00ffffffffffff0009e5df0800000000251d0104a52213780754a5a7544c9b260f505400000001010101010101010101010101010101988980a0703860403020360058c21000001a000000000000000000000000000000000000000000fe00424f452043510a202020202020000000fe004e5631353646484d2d4e59340a00fd";
        imac = "00ffffffffffff0049f7000000000000191a0103800000000ad7a5a2594a9624145054afce00d1c0b30081008180814081c001010101023a801871382d40582c45003f432100001a7f2156aa51001e30468f33003f432100001e000000fd00324c1e5010000a202020202020000000fc004141410a2020202020202020200164020323744f109f1405041312161115030702060123090f038301000066030c00100080011d00bc52d01e20b8285540c48e2100001e011d80d0721c1620102c2580c48e2100009e8c0ad08a20e02d10103e9600138e210000188c0ad090204031200c405500138e2100001800000000000000000000000000000000000000009d";
        dell = "00ffffffffffff0010ac7aa04c4d50343415010380342078eaee95a3544c99260f5054a1080081408180a940b300d1c0010101010101283c80a070b023403020360006442100001a000000ff00593148355431434f34504d4c0a000000fc0044454c4c2055323431324d0a20000000fd00323d1e5311000a20202020202000da";
      };
      config = {
        integrated = {
          resolution = "1920x1080";
          rate = "144.00";
        };
        imac = {
          resolution = "1920x1080";
          rate = "60.00";
        };
        dell = {
          resolution = "1920x1200";
          rate = "59.95";
        };
      };
    in {
      mobile = {
        fingerprint = {
          eDP-1 = fingerprints.integrated;
        };
        config = {
          eDP-1 = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = config.integrated.resolution;
            rate = config.integrated.rate;
          };
        };
      };
      desk = {
        fingerprint = {
          eDP-1 = fingerprints.integrated;
          DVI-I-3-2 = fingerprints.imac;
          DVI-I-2-1 = fingerprints.dell;
        };
        config = {
          eDP-1 = {
            enable = true;
            primary = false;
            position = "0x230";
            mode = config.integrated.resolution;
            rate = config.integrated.rate;
          };
          DVI-I-3-2 = {
            enable = true;
            primary = true;
            position = "1920x0";
            mode = config.imac.resolution;
            rate = config.imac.rate;
          };
          DVI-I-2-1 = {
            enable = true;
            primary = false;
            position = "3840x0";
            mode = config.dell.resolution;
            rate = config.dell.rate;
          };
        };
      };
    };
  };

  services.xserver.xkb = {
    layout = "ch";
    variant = "fr";
  };
  services.libinput.enable = true;

  # Configure console keymap
  console.keyMap = "fr_CH";

  environment.cinnamon.excludePackages = with pkgs; [
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    cheese # webcam tool
    baobab # disk usage
    totem # video player
    eog # image viewer
    evince # document viewer
    seahorse # password manager
    epiphany # web browser
    geary # email reader
    yelp # Help view
    simple-scan
    gnome-logs
    gnome-characters
    gnome-music
    gnome-contacts
    gnome-initial-setup
    gnome-characters
    gnome-clocks
    gnome-maps
    gnome-weather
    gnome-calculator
    gnome-calendar
    gnome-font-viewer
    gnome-disk-utility
    gnome-photos
    gnome-tour
    loupe # image viewer
  ];
}
