{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
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
