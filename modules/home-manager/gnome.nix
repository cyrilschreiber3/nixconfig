{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    gnome.gnome-tweaks
    gnomeExtensions.dashbar
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dashbar"
      ];
    };
  };
}
