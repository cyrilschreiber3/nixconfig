{
  config,
  pkgs,
  ...
}: {
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
    };
  };
}
