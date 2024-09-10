{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # ./../../modules/home-manager/btop.nix
    # ./../../modules/home-manager/git.nix
    # ./../../modules/home-manager/zsh.nix
    inputs.main-config.homeManagerModules.zsh
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "admin";
  home.homeDirectory = "/home/admin";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # cli
    git
    gh
    tree
    unzip
    rclone
    ondir
    nix-output-monitor
    btop
    nano
    rsync
    screen
    neofetch
  ];

  home.file = {
  };

  home.sessionVariables = {
  };

  zshConfig = {
    enable = true;
    enableCinnamonDE = false;
    useLegacyP10k = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
