{
  pkgs,
  pkgs-stable,
  ...
}: {
  hardware.graphics = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    package = pkgs-stable.steam;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup
    lutris
    bottles
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/cyril/.steam/root/compatibilitytools.d";
  };
}
