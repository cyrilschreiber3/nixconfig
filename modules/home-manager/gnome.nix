{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    gnomeExtensions.dash-to-panel
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dash-to-panel"
      ];
    };
  };
}
