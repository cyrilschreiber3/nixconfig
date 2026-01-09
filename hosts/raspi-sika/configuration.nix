# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  lib,
  pkgs,
  inputs,
  ...
}: let
in {
  imports = [
    ./hardware-configuration.nix
    inputs.main-config.nixosModules.mainUser
    inputs.bar-sika.nixosModules.default
    inputs.sops-nix.nixosModules.sops
  ];

  nixpkgs.overlays = [
    inputs.bar-sika.overlays.default
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    secrets.wifi-passwords = {
      format = "yaml";
      key = "passwords";
      sopsFile = ./../../dotfiles/wifi-networks.yaml;
    };
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
    settings.trusted-users = [
      "root"
      "cyril"
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
    userName = "cyril";
    fullUserName = "Cyril";
    extraGroups = ["networkmanager" "wheels" "audio" "gpio"];
    importSshKeysFromGithub = true;
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

  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    git
    tree
    tmux
    python3

    usbutils
    pigpio
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = true;
    };
  };

  services.bar-sika = {
    enable = true;
    enablePigpiodService = true;
  };

  system.stateVersion = "24.11";
}
