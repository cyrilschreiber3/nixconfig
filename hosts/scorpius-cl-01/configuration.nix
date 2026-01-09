# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  lib,
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./display.nix
    ./../../modules/nixos
    ./../../modules/specialisations
    inputs.home-manager.nixosModules.default
  ];

  # Overlays
  nixpkgs.overlays = [
    outputs.overlays.stable-packages
    outputs.overlays.my-packages
    outputs.overlays.my-packages-2405
  ];

  # Bootloader
  boot.loader = {
    # Set the bootloader to use the main partition for kernel and initrd
    efi = {
      # canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      #  device = "/dev/sda"; # no need to set devices, disko will add all devices that have a EF02 partition to the list already
      useOSProber = true;
    };
    timeout = 2; # Time before booting the default entry
  };

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  boot.supportedFilesystems = ["ntfs"];

  # For Star Citizen: https://github.com/starcitizen-lug/knowledge-base/wiki/Tips-and-Tricks#nixos
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

  boot.plymouth.enable = true;
  boot.plymouth.theme = "loader_2";
  boot.plymouth.themePackages = [
    (pkgs.mypkgs.adi1090x-plymouth-themes.override
      {
        selected_themes = ["connect" "loader_2" "spinner_alt"];
        display_nixos_logo = true;
      })
  ];

  # Enable networking
  networking.hostName = "scorpius-cl-01";
  networking.search = ["schreibernet.dev"];
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce []; # Disable wait-online for faster boot
  networking.networkmanager.dns = "systemd-resolved";
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "192.168.1.13"
    "10.1.1.51"
    "10.1.1.52"
    "192.168.1.1"
  ];
  networking.resolvconf.extraOptions = [
    "timeout:2"
    "attempts:1"
    # "rotate"
  ];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    # SSH
    22
    # Generic dev
    8080
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

  # Limit journald log size to keep fast boot times
  services.journald.extraConfig = "SystemMaxUse=50M";

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

  # Enable sound with pipewire.
  # services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire = {
      "10-split-surround-output" = {
        "context.modules" = [
          {
            name = "libpipewire-module-loopback";
            args = {
              "node.description" = "Scarlett Solo Input 1";
              "capture.props" = {
                "audio.position" = ["FL"];
                "stream.dont-remix" = true;
                "target.object" = "alsa_input.usb-Focusrite_Scarlett_Solo_4th_Gen_S1DVHEG360E2D1-00.analog-surround-40";
                "node.passive" = true;
              };
              "playback.props" = {
                "node.name" = "SF_in_1";
                "media.class" = "Audio/Source";
                "audio.position" = ["MONO"];
              };
            };
          }
          {
            name = "libpipewire-module-loopback";
            args = {
              "node.description" = "Scarlett Solo Input 2";
              "capture.props" = {
                "audio.position" = ["FR"];
                "stream.dont-remix" = true;
                "target.object" = "alsa_input.usb-Focusrite_Scarlett_Solo_4th_Gen_S1DVHEG360E2D1-00.analog-surround-40";
                "node.passive" = true;
              };
              "playback.props" = {
                "node.name" = "SF_in_2";
                "media.class" = "Audio/Source";
                "audio.position" = ["MONO"];
              };
            };
          }
          {
            name = "libpipewire-module-loopback";
            args = {
              "node.description" = "Scarlett Solo Input Loopback";
              "capture.props" = {
                "audio.position" = ["RL" "RR"];
                "stream.dont-remix" = true;
                "target.object" = "alsa_input.usb-Focusrite_Scarlett_Solo_4th_Gen_S1DVHEG360E2D1-00.analog-surround-40";
                "node.passive" = true;
              };
              "playback.props" = {
                "node.name" = "SF_in_LB";
                "media.class" = "Audio/Source";
                "audio.position" = ["FL" "FR"];
              };
            };
          }
        ];
      };
    };
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.hardware.bolt.enable = true;

  # Enable the OpenSSH server.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Enable Docker
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  mainUser = {
    enable = true;
    userName = "cyril";
    fullUserName = "Cyril Schreiber";
    extraGroups = ["networkmanager" "wheels" "audio" "docker"];
    importSshKeysFromGithub = true;
  };

  home-manager = {
    # extraSpecialArgs = {inherit inputs mypkgs mypkgs-2405;};
    extraSpecialArgs = {inherit inputs outputs;};
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

  # Enable udisks2 to mount USB drives
  services.udisks2.enable = true;

  services.pcscd.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Editors
    vim
    nano

    # Networking
    wget
    curl
    iperf

    # Hardware Info
    nvtopPackages.full
    pciutils
    usbutils

    # Filesystem
    ntfs3g
    bashmount

    # Audio
    alsa-scarlett-gui
    scarlett2

    # Package Management
    cachix
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

  gamesConfig = {
    enable = true;
  };

  printersConfig = {
    enable = true;
  };

  sopsConfig = {
    enable = true;
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
