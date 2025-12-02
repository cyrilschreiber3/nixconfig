{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cinnamonConfig;
in {
  options.cinnamonConfig = {
    enable = lib.mkEnableOption "Enable Cinnamon tweaks";
    enableSharesBookmarks = lib.mkEnableOption "Enable shares bookmarks";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      albert
      diodon
      zeitgeist
    ];

    themes.themeGTK = true;

    home.sessionVariables = {
      ZEITGEIST_DATABASE_PATH = ":memory:";
    };

    xdg.configFile = {
      "autostart/albert.desktop".source = "${pkgs.albert}/share/applications/albert.desktop";
      "albert/config".source = "${pkgs.copyPathToStore ./../dotfiles/albert/albert.conf}";
      "albert/websearch/engines.json".source = "${pkgs.copyPathToStore ./../dotfiles/albert/albert_search.json}";
      "cinnamon/spices/".source = "${pkgs.copyPathToStore ./../dotfiles/cinnamon}";
      "gtk-3.0/bookmarks".text = lib.mkMerge [
        ''
          file:///home/cyril/Documents Documents
          file:///home/cyril/Downloads Downloads
        ''
        (lib.mkIf cfg.enableSharesBookmarks ''
          file:///mnt/Media1 Media1
          file:///mnt/Media2 Media2
          file:///mnt/TurboVault TurboVault
          file:///mnt/Vault Vault
        '')
      ];
    };

    dconf.settings = {
      "org/cinnamon" = {
        favorite-apps = [
          "nemo.desktop"
          "firefox.desktop"
          "org.gnome.Terminal.desktop"
          "cinnamon-settings.desktop"
        ];
        app-menu-icon-name = "nix-snowflake-white";
        system-icon = "nix-snowflake-white";
        device-aliases = ["/org/freedesktop/UPower/devices/battery_BAT1:=Main Battery"];
        enabled-applets = ["panel1:left:0:menu@cinnamon.org:0" "panel1:left:1:separator@cinnamon.org:1" "panel1:left:2:grouped-window-list@cinnamon.org:2" "panel1:right:0:systray@cinnamon.org:3" "panel1:right:1:xapp-status@cinnamon.org:4" "panel1:right:2:notifications@cinnamon.org:5" "panel1:right:4:removable-drives@cinnamon.org:7" "panel1:right:7:network@cinnamon.org:10" "panel1:right:8:sound@cinnamon.org:11" "panel1:right:9:power@cinnamon.org:12" "panel1:right:10:calendar@cinnamon.org:13" "panel1:right:11:cornerbar@cinnamon.org:14"];
      };
      "org/cinnamon/desktop/wm/preferences" = {
        button-layout = ":minimize,maximize,close";
      };
      "org/cinnamon/desktop/background" = {
        picture-uri = "file://${pkgs.copyPathToStore ./../../modules/assets/wallpaper.jpg}";
        picture-uri-dark = "file://${pkgs.copyPathToStore ./../../modules/assets/wallpaper.jpg}";
        picture-options = "zoom";
      };
      "org/cinnamon/desktop/keybindings" = {
        custom-list = ["custom0" "custom1"];
      };
      "org/cinnamon/desktop/keybindings/custom-keybindings/custom0" = {
        name = "Albert";
        command = "${pkgs.albert}/bin/albert toggle";
        binding = ["<Super>space"];
      };
      "org/cinnamon/desktop/keybindings/custom-keybindings/custom1" = {
        name = "Diodon";
        command = "${pkgs.diodon}/bin/diodon";
        binding = ["<Super>v"];
      };
      "org/cinnamon/desktop/keybindings/media-keys" = {
        terminal = ["<Super>t"];
      };
      "org/cinnamon/settings-daemon/plugins/power" = {
        sleep-display-ac = 1800; # 30min
        sleep-display-battery = 1800; # 30min
        sleep-inactive-ac-timeout = 0; # never
        sleep-inactive-battery-timeout = 0; # never
        lid-close-ac-action = "nothing";
        lid-close-battery-action = "suspend";
        button-power = "interactive";
        idle-dim-battery = true;
        idle-dim-time = 120; # 2min
        idle-brightness = 30;
      };
      "org/cinnamon/theme" = {
        name = config.gtk.theme.name;
      };
      "/org/gnome/desktop/interface" = {
        gtk-theme = config.gtk.theme.name;
        icon-theme = config.gtk.iconTheme.name;
        cursor-theme = config.gtk.cursorTheme.name;
        color-scheme = "prefer-${config.global.theme.variant}";
      };
      "org/cinnamon/desktop/interface" = {
        gtk-theme = config.gtk.theme.name;
        icon-theme = config.gtk.iconTheme.name;
        cursor-theme = config.gtk.cursorTheme.name;
      };
      "org/nemo/preferences" = {
        default-folder-viewer = "icon-view";
        show-open-in-terminal-toolbar = true;
      };
      "org/nemo/preferences/menu-config" = {
        selection-menu-make-link = true;
      };
      "org/nemo/window-state" = {
        geometry = "1244x730+1989+35";
        sidebar-bookmark-breakpoint = 2;
      };
      "org/gnome/terminal/legacy/profiles:/:273f07db-8f33-49f7-8909-da4b9946a21f" = {
        default-size-columns = lib.hm.gvariant.mkInt32 125;
        default-size-rows = lib.hm.gvariant.mkInt32 32;
      };
      "org/cinnamon/desktop/a11y/applications" = {
        screen-keyboard-enabled = false;
        togglekeys-enable-osd = true;
      };
      "org/x/apps/portal" = {
        color-scheme = "prefer-${config.global.theme.variant}";
      };
      "org/x/editor/preferences/editor" = {
        bracket-matching = true;
        display-line-numbers = true;
      };
      "org/x/pix/browser" = {
        maximized = true;
        thumbnail-list-visible = false;
      };
      "net/launchpad/diodon/clipboard" = {
        use-clipboard = true;
        use-primary = false;
        add-images = true;
        keep-clipboard-content = true;
        synchronize-clipboard = false;
        instant-paste = true;
        recent-items-size = 20;
      };
      "net/launchpad/diodon/plugins" = {
        active-plugins = [];
      };
    };

    programs.gnome-terminal = let
      colors = config.global.theme.colorPalette;
    in {
      enable = true;
      themeVariant = colors.variant;
      showMenubar = false;
      profile = {
        "273f07db-8f33-49f7-8909-da4b9946a21f" = {
          default = true;
          visibleName = config.global.theme.prettyName;
          cursorShape = "block";
          transparencyPercent = 30;
          font = "${config.global.fonts.monospace} 10";
          colors = {
            backgroundColor = colors.background;
            foregroundColor = colors.foreground;
            cursor = {
              foreground = colors.background;
              background = colors.foreground;
            };
            palette = [
              colors.color00
              colors.color01
              colors.color02
              colors.color03
              colors.color04
              colors.color05
              colors.color06
              colors.color07
              colors.color08
              colors.color09
              colors.color10
              colors.color11
              colors.color12
              colors.color13
              colors.color14
              colors.color15
            ];
          };
        };
      };
    };
  };
}
/*
If cinnamon is enabled, you can exclude it's default packages from your nixos configuration like this:

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
*/

