{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cinnamonConfig;

  themeName = "Tokyonight-Dark-BL-LB";
  iconThemeName = "WhiteSur-dark";
  cursorThemeName = "WhiteSur-cursors";
in {
  options.cinnamonConfig = {
    enable = lib.mkEnableOption "Enable Cinnamon tweaks";
    enableSharesBookmarks = lib.mkEnableOption "Enable shares bookmarks";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      sassc
      gtk-engine-murrine
      gnome-themes-extra
      dconf-editor
      albert
      gpaste

      (whitesur-icon-theme.override {
        alternativeIcons = true;
      })
    ];

    gtk = {
      enable = true;
      theme = {
        name = themeName;
        package = "${import ./../themes/tokyonight-gtk-theme.nix {inherit pkgs;}}";
      };
      cursorTheme = {
        name = cursorThemeName;
        package = pkgs.whitesur-cursors;
      };
      iconTheme = {
        name = iconThemeName;
      };
    };

    home.sessionVariables.GTK_THEME = "Tokyonight-Dark-BL-LB";

    xdg.configFile = {
      "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
      "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
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
        command = "albert toggle";
        binding = ["<Super>space"];
      };
      "org/cinnamon/desktop/keybindings/custom-keybindings/custom1" = {
        name = "GPaste";
        command = "gpaste";
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
        name = themeName;
      };
      "org/cinnamon/desktop/interface" = {
        gtk-theme = themeName;
        icon-theme = iconThemeName;
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/interface" = {
        gtk-theme = themeName;
        icon-theme = iconThemeName;
        color-scheme = "prefer-dark";
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
      "org/cinnamon/desktop/a11y/applications" = {
        screen-keyboard-enabled = false;
        togglekeys-enable-osd = true;
      };
      "org/x/apps/portal" = {
        color-scheme = "prefer-dark";
      };
      "org/x/editor/preferences/editor" = {
        bracket-matching = true;
        display-line-numbers = true;
      };
      "org/x/pix/browser" = {
        maximized = true;
        thumbnail-list-visible = false;
      };
    };
  };
}
