{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.spotifyConfig;
in {
  options.spotifyConfig = {
    enable = lib.mkEnableOption "Enable Spotify module";
    enableSpicetify = lib.mkEnableOption "Enable Spicetify tweaks";
  };

  imports = lib.optional cfg.enable [inputs.spicetify-nix.homeManagerModules.default];

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (!cfg.enableSpicetify) (with pkgs; [
      spotify
    ]);

    programs.spicetify = let
      tokyonightTheme = pkgs.fetchFromGitHub {
        owner = "Gspr-bit";
        repo = "Spotify-Tokyo-Night-Theme";
        rev = "d88ca06eaeeb424d19e0d6f7f8e614e4bce962be";
        hash = "sha256-cLj9v8qtHsdV9FfzV2Qf4pWO8AOBXu51U/lUMvdEXAk=";
      };
      spicepkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
      lib.mkIf cfg.enableSpicetify {
        enable = true;
        spotifyPackage = pkgs.spotify;
        theme = {
          name = "Tokyo";
          src = tokyonightTheme;
          injectCss = true;
          replaceColors = true;
          overwriteAssets = true;
          sidebarConfig = true;
          homeConfig = true;
        };
        colorScheme = "Night";
        enabledExtensions = with spicepkgs.extensions; [
          hidePodcasts
          shuffle
          songStats
          betterGenres
          playNext
        ];
      };

    # Force Spotify to use X11 backend
    xdg.desktopEntries.spotify = {
      name = "Spotify";
      genericName = "Music Player";
      icon = "${pkgs.whitesur-icon-theme}/share/icons/WhiteSur-dark/apps/scalable/spotify.svg";
      exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=x11 %U";
      terminal = false;
      mimeType = ["x-scheme-handler/spotify"];
      categories = ["Audio" "Music" "Player" "AudioVideo"];
    };
  };
}
