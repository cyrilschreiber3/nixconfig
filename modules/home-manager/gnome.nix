{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    gnomeExtensions.dash-to-dock
    gnomeExtensions.user-themes
  ];

  gtk = {
    enable = true;
    theme = {
      name = "whitesur-dark";
      package = pkgs.whitesur-gtk-theme;
    };
    cursorTheme = {
      name = "whitesur-cursors";
      package = pkgs.whitesur-cursors;
    };
    iconTheme = {
      name = "WhiteSur";
      package = pkgs.whitesur-icon-theme;
    };
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
      ];
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "whitesur-gtk-theme";
    };
  };
}
