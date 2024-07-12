# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  ...
}: let
  mypkgs = inputs.mypkgs.packages.${pkgs.system};
in {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/nixos/mainUser.nix
    ./../../modules/nixos/cachix/cachix.nix
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
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

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    warn-dirty = false
  '';

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.wallpaper.combineScreens = true;
  services.xserver.desktopManager.wallpaper.mode = "fill";
  programs.dconf.enable = true;

  environment.gnome.excludePackages = with pkgs.gnome;
    [
      cheese # webcam tool
      baobab # disk usage
      totem # video player
      eog # image viewer
      evince # document viewer
      seahorse # password manager
      epiphany # web browser
      geary # email reader
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # Help view
      simple-scan
      gnome-calculator
      gnome-logs
      gnome-characters
      gnome-music
      gnome-contacts
      gnome-initial-setup
      gnome-characters
      gnome-calendar
      gnome-clocks
      gnome-font-viewer
      gnome-maps
      gnome-weather
      gnome-disk-utility
    ]
    ++ (with pkgs; [
      gnome-photos
      gnome-tour
      loupe # image viewer
    ]);

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ch";
    variant = "fr";
  };

  # Configure console keymap
  console.keyMap = "fr_CH";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # nix.optimise.automatic = true;
  # nix.optimise.dates = "weekly";
  nix.settings.auto-optimise-store = true;

  # Enable the OpenSSH server.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  mainUser.enable = true;
  mainUser.userName = "cyril";
  mainUser.fullUserName = "Cyril Schreiber";
  mainUser.extraGroups = ["networkmanager" "wheels"];

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

  programs.zsh.enable = true;

  programs.nix-ld.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      vim
      nano
      wget
      curl
      nix-output-monitor
      cachix
    ]
    ++ [
      mypkgs.yuzu
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
