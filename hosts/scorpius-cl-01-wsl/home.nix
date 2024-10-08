{pkgs, ...}: {
  imports = [
    ./../../modules/home-manager/btop.nix
    ./../../modules/home-manager/git.nix
    ./../../modules/home-manager/zsh.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "cyril";
  home.homeDirectory = "/home/cyril";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # media
    ffmpeg
    yt-dlp

    # cli
    git
    gh
    tree
    unzip
    rclone
    ondir
    libnotify
    nix-output-monitor
    btop
    nano
    rsync
    screen
    neofetch

    # dev
    nixd
    alejandra
    nixpkgs-fmt

    (writeShellScriptBin "rebuild" (builtins.readFile ./../../modules/bin/rebuild.sh))
  ];

  home.file = {
  };

  home.sessionVariables = {
  };

  gitConfig = {
    enable = true;
    enableGPG = true;
    useWindowsPinentry = true;
  };

  zshConfig = {
    enable = true;
    enableCinnamonDE = false;
    useLegacyP10k = false;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
