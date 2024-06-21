{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    gnomeExtensions.dashbar
  ];

  dconf.settings = {
  };
}
