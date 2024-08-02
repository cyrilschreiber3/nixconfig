{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    sassc
    gtk-engine-murrine
    gnome-themes-extra
    dconf-editor

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
  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  dconf.settings = {
    "org/cinnamon" = {
      favorite-apps = [
        "nemo.desktop"
        "firefox.desktop"
        "org.gnome.Terminal.desktop"
        "cinnamon-settings.desktop"
      ];
    };
    "org/cinnamon/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };
    "org/cinnamon/desktop/background" = {
      picture-uri = "file://${pkgs.copyPathToStore ./../../modules/assets/wallpaper.jpg}";
      picture-uri-dark = "file://${pkgs.copyPathToStore ./../../modules/assets/wallpaper.jpg}";
      picture-options = "zoom";
    };
  };
}
