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
      sassc
      gtk-engine-murrine
      gnome-themes-extra
      dconf-editor
      albert

      (whitesur-icon-theme.override {
        alternativeIcons = true;
      })
    ];

    gtk = {
      enable = true;
      theme = {
        name = "Tokyonight-Dark-BL-LB";
        package = "${import ./../themes/tokyonight-gtk-theme.nix {inherit pkgs;}}";
      };
      cursorTheme = {
        name = "WhiteSur-cursors";
        package = pkgs.whitesur-cursors;
      };
      iconTheme = {
        name = "WhiteSur";
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
        custom-list = ["custom0"];
      };
      "org/cinnamon/desktop/keybindings/custom-keybindings/custom0" = {
        name = "Albert";
        command = "albert toggle";
        binding = ["<Super>space"];
      };
      "org/cinnamon/desktop/keybindings/media-keys" = {
        terminal = ["<Super>t"];
      };
      "org/cinnamon/theme" = {
        name = "Tokyonight-Dark-BL-LB";
      };
      "org/cinnamon/desktop/interface" = {
        gtk-theme = "Tokyonight-Dark-BL-LB";
        icon-theme = "WhiteSur";
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/interface" = {
        gtk-theme = "Tokyonight-Dark-BL-LB";
        icon-theme = "WhiteSur";
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
      "org/x/pix/browser" = {
        maximized = true;
        thumbnail-list-visible = false;
      };
    };
  };
}
