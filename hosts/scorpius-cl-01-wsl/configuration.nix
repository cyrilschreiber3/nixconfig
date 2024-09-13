{
  pkgs,
  inputs,
  ...
}: {
  imports = [
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  wsl.interop.register = true;

  wsl.enable = true;
  wsl.defaultUser = "cyril";
  users.users."cyril".shell = pkgs.zsh;

  networking.hostName = "scorpius-cl-01-wsl";
  wsl.wslConf.network.generateResolvConf = false;
  networking.nameservers = [
    "192.138.1.85"
    "192.168.1.32"
    "1.1.1.1"
  ];
  networking.search = [
    "schreibernet.dev"
  ];

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

  security.sudo = {
    enable = true;
    extraRules = [
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
  };

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
