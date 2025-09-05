{
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # display color management
    colord
    xcalib
    argyllcms
    xorg.xgamma
    (pkgs.makeDesktopItem {
      name = "autorandr-refresh";
      desktopName = "Autorandr refresh";
      comment = "Refresh autorandr configuration";
      exec = "${pkgs.autorandr}/bin/autorandr --change --match-edid";
      icon = "utilities-terminal";
      terminal = false;
      categories = ["Utility" "System"];
      genericName = "Update display configuration";
      keywords = ["autorandr" "refresh" "display" "fix" "reload"];
    })
  ];

  # Enable the X11 windowing system, lightdm display manager and cinnamon desktop environment.
  services.xserver = {
    enable = true;
    dpi = lib.mkDefault 104;
    # videoDrivers = ["nvidia"];
    videoDrivers = ["nvidia" "displaylink"];
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
    hooks.postswitch = {
      notify-display-change = ''${pkgs.libnotify}/bin/notify-send -i display "Display profile" "$AUTORANDR_CURRENT_PROFILE"'';
    };
    defaultTarget = "mobile";
    profiles = let
      fingerprints = {
        integrated = "00ffffffffffff0009e5df0800000000251d0104a52213780754a5a7544c9b260f505400000001010101010101010101010101010101988980a0703860403020360058c21000001a000000000000000000000000000000000000000000fe00424f452043510a202020202020000000fe004e5631353646484d2d4e59340a00fd";
        imac = "00ffffffffffff0049f7000000000000191a0103800000000ad7a5a2594a9624145054afce00d1c0b30081008180814081c001010101023a801871382d40582c45003f432100001a7f2156aa51001e30468f33003f432100001e000000fd00324c1e5010000a202020202020000000fc004141410a2020202020202020200164020323744f109f1405041312161115030702060123090f038301000066030c00100080011d00bc52d01e20b8285540c48e2100001e011d80d0721c1620102c2580c48e2100009e8c0ad08a20e02d10103e9600138e210000188c0ad090204031200c405500138e2100001800000000000000000000000000000000000000009d";
        odyssey = "00ffffffffffff004c2d5fe00006000014220103805123782abc55b04d3db7250f5054210800810081c081809500a9c0b300010101016d8870a0d0a0b25030203a0029623100001a000000fd0030af1eff69000a202020202020000000fc004f647973736579204738355344000000ff004831414b3530303030300a2020012f020360f0e2780344103f04032f0d5707150750570700675400090707830f0000e2004fe305c30168030c002000b844086dd85dc4017880580030afc3540b741a0000030730af00a060054b0faf000000000000e6060501604b00e5018b849039565e00a0a0a029503020350029623100001a0000000000000000000000000074020304f06fc200a0a0a055503020350029623100001a023a801871382d40582c450029623100001e0474801871382d40582c450029623100001efea680a070385f403020350029623100001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003a701279030003013cf21001886f0d9f00";
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
        odyssey = {
          resolution = "2560x1440";
          rate = "59.96";
        };
        dell = {
          resolution = "1920x1200";
          rate = "59.95";
        };
      };
    in {
      mobile = {
        fingerprint = {
          integrated = fingerprints.integrated;
        };
        config = {
          integrated = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = config.integrated.resolution;
            rate = config.integrated.rate;
          };
        };
      };
      deskNew = {
        fingerprint = {
          integrated = fingerprints.integrated;
          imac = fingerprints.imac;
          dell = fingerprints.dell;
          odyssey = fingerprints.odyssey;
        };
        config = {
          integrated = {
            enable = false;
            # primary = false;
            # position = "0x230";
            # mode = config.integrated.resolution;
            # rate = config.integrated.rate;
          };
          imac = {
            enable = true;
            primary = false;
            position = "0x180";
            mode = config.imac.resolution;
            rate = config.imac.rate;
          };
          odyssey = {
            enable = true;
            primary = true;
            position = "1920x0";
            mode = config.odyssey.resolution;
            rate = config.odyssey.rate;
          };
          dell = {
            enable = true;
            primary = false;
            position = "4080x120";
            mode = config.dell.resolution;
            rate = config.dell.rate;
          };
        };
      };
      desk = {
        fingerprint = {
          integrated = fingerprints.integrated;
          imac = fingerprints.imac;
          dell = fingerprints.dell;
        };
        config = {
          integrated = {
            enable = true;
            primary = false;
            position = "0x230";
            mode = config.integrated.resolution;
            rate = config.integrated.rate;
          };
          imac = {
            enable = true;
            primary = true;
            position = "1920x0";
            mode = config.imac.resolution;
            rate = config.imac.rate;
          };
          dell = {
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

  services.logind = {
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitch = "ignore";
  };

  services.upower.ignoreLid = true;

  # Run autorandr on startup
  # environment.etc."xdg/autostart/autorandr-init.desktop" = {
  #   text = ''
  #     [Desktop Entry]
  #     Type=Application
  #     Name=Autorandr init
  #     Description=Apply autorandr configuration once the graphical session is ready.
  #     Exec=${pkgs.autorandr}/bin/autorandr --change --match-edid
  #     X-GNOME-Autostart-enabled=true
  #   '';
  #   mode = "0644";
  # };

  # services.udev.extraRules = ''
  #   ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.autorandr}/bin/autorandr --change --match-edid"
  # '';

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
