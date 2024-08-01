{
  config,
  pkgs,
  lib,
  ...
}: {
  home.file = {
    ".local/share/color-schemes/TokyoNight.colors".source = "${pkgs.callPackage ./../themes/tokyonight-kde-colors.nix {}}/share/color-schemes/TokyoNight.colors";
  };

  qt = {
    enable = true;
    # platformTheme.name = "gnome";
  };
}
