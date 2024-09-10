{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
  ];

  wsl.enable = true;
  wsl.defaultUser = "cyril";
  users.users."cyril".shell = pkgs.zsh;

  networking.hostName = "scorpius-cl-01-wsl";

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';

    settings.auto-optimise-store = true;
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "backup";
    users = {
      "cyril" = import ./home.nix;
    };
  };

  security.sudo.extraRules = [
    {
      users = ["cyril"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    zsh.enable = true;
    nix-ld.enable = true;
    nix-ld.package = pkgs.nix-ld-rs;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    nano
    wget
    curl
    cachix
  ];

  system.stateVersion = "24.05";
}
