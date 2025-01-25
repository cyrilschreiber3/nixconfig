# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./display.nix
    ./../../modules/nixos
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda"; # no need to set devices, disko will add all devices that have a EF02 partition to the list already
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.useOSProber = true;

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  boot.supportedFilesystems = ["ntfs"];

  # Enable networking
  networking.hostName = "scorpius-cl-01";
  networking.search = ["schreibernet.dev"];
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [
    "192.168.1.85"
    "192.168.1.32"
    "1.1.1.1"
  ];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    # SSH
    22
    # Spotify
    57621
  ];
  networking.firewall.allowedUDPPorts = [
    # Spotify
    5353
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # optimise.automatic = true;
    # optimise.dates = "weekly";
    settings.auto-optimise-store = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
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

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable the OpenSSH server.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  mainUser = {
    enable = true;
    userName = "cyril";
    fullUserName = "Cyril Schreiber";
    extraGroups = ["networkmanager" "wheels"];
    importSshKeysFromGithub = true;
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    # sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
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

  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    curl
    cachix
    nvtopPackages.full
  ];

  programs = {
    dconf.enable = true;
    zsh.enable = true;
    nix-ld.enable = true;
  };

  autofsConfig = {
    enable = true;
    enabledDefaultShares = ["media1" "media2" "turboVault" "vault"];
    customShares = [];
  };

  vGPUVMConfig = {
    enable = true;
    cpuType = "intel";
    pciIDs = "15b7:5030";
    mainUser = "cyril";
  };

  wireguardClientConfig = {
    enable = false;
    enableSchreibernet = true;
  };

  x11vncConfig = {
    enable = true;
    mainUser = "cyril";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
