{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.spicetify-nix.homeManagerModule];
  programs.spicetify = let
    tokyonightTheme = pkgs.fetchgit {
      url = "https://github.com/Gspr-bit/Spotify-Tokyo-Night-Theme";
      rev = "d88ca06eaeeb424d19e0d6f7f8e614e4bce962be";
      sha256 = "sha256-cLj9v8qtHsdV9FfzV2Qf4pWO8AOBXu51U/lUMvdEXAk=";
    };
  in {
    enable = true;
    spotifyPackage = pkgs.spotify;
    theme = {
      name = "Tokyo";
      src = tokyonightTheme;
      appendName = false;
      injectCss = true;
      replaceColors = true;
      overwriteAssets = true;
      sidebarConfig = true;
    };
    colorScheme = "Night";
  };

  # Force Spotify to use X11 backend
  # xdg.desktopEntries.spotify = {
  #   name = "Spotify";
  #   exec = "${pkgs.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=x11 %U";
  # };
}
