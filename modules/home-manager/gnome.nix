{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    sassc
    gtk-engine-murrine
    gnome.gnome-themes-extra
    gnome.dconf-editor
    gnomeExtensions.dash-to-panel
    gnomeExtensions.user-themes
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.search-light

    (whitesur-icon-theme.override {
      alternativeIcons = true;
    })
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark-BL-LB";
      package = pkgs.tokyonight-gtk-theme;
    };
    # cursorTheme = {
    #   name = "WhiteSur-cursors";
    #   package = pkgs.whitesur-cursors;
    # };
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
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "just-perfection-desktop@just-perfection"
        "blur-my-shell@aunetx"
      ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "org.gnome.Console.desktop"
      ];
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = true;
      require-pressure-to-show = false;
      show-apps-at-top = true;
      dock-position = "BOTTOM";
      multi-monitor = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      "button-layout" = ":minimize,maximize,close";
    };
    # "org/gnome/desktop/background" = {
    #   picture-uri = "file://${config.home}/.background-image.jpg";
    #   picture-uri-dark = "file://${config.home}/.background-image.jpg";
    #   picture-options = "zoom";
    # };
  };
}
