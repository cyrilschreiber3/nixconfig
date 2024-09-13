# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/nixos/wireguard.nix

    inputs.main-config.nixosModules.mainUser
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "aquila-vpn-01";

  # Networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    # SSH
    22
  ];
  networking.firewall.allowedUDPPorts = [
    # Wireguard
    51820
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
    settings.trusted-users = [
      "root"
      "admin"
      "@wheel"
    ];
    settings.auto-optimise-store = true;
  };

  time.timeZone = "Europe/Zurich";

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_NUMERIC = "fr_CH.UTF-8";
    LC_TIME = "en_IE.UTF-8";
    LC_MONETARY = "fr_CH.UTF-8";
    LC_PAPER = "fr_CH.UTF-8";
    LC_NAME = "fr_CH.UTF-8";
    LC_ADDRESS = "fr_CH.UTF-8";
    LC_TELEPHONE = "fr_CH.UTF-8";
    LC_MEASUREMENT = "fr_CH.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr_CH";
  };

  mainUser = {
    enable = true;
    userName = "admin";
    fullUserName = "Local Admin";
    extraGroups = ["networkmanager" "wheels"];
    importSshKeysFromGithub = true;
  };

  security.sudo.extraRules = [
    {
      users = ["admin"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "backup";
    users = {
      "admin" = import ./home.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tree
    python3
  ];

  programs = {
    zsh.enable = true;
    nix-ld.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  system.stateVersion = "24.11";
}
