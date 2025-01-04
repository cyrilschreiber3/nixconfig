# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  ...
}: {
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

  networking.hostName = "scorpius-cl-01";
  networking.nameservers = [
    "192.138.1.85"
    "192.168.1.32"
    "1.1.1.1"
  ];
  networking.search = [
    "schreibernet.dev"
  ];
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.slick = {
      enable = true;
      theme = {
        name = "Tokyonight-Dark-BL-LB";
        package = "${pkgs.callPackage ./../../modules/themes/tokyonight-gtk-theme.nix {}}";
      };
      cursorTheme = {
        name = "WhiteSur-cursors";
        package = pkgs.whitesur-cursors;
      };
    };
    background = "${pkgs.copyPathToStore ./../../modules/assets/login-wallpaper.jpg}";
  };
  services.xserver.desktopManager.cinnamon.enable = true;
  services.xserver.desktopManager.wallpaper.combineScreens = true;
  services.xserver.desktopManager.wallpaper.mode = "fill";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ch";
    variant = "fr";
  };
  services.libinput.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Configure console keymap
  console.keyMap = "fr_CH";

  environment.cinnamon.excludePackages = with pkgs; [
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    cheese # webcam tool
    baobab # disk usage
    totem # video player
    eog # image viewer
    evince # document viewer
    seahorse # password manager
    epiphany # web browser
    geary # email reader
    yelp # Help view
    simple-scan
    gnome-logs
    gnome-characters
    gnome-music
    gnome-contacts
    gnome-initial-setup
    gnome-characters
    gnome-clocks
    gnome-maps
    gnome-weather
    gnome-calculator
    gnome-calendar
    gnome-font-viewer
    gnome-disk-utility
    gnome-photos
    gnome-tour
    loupe # image viewer
  ];

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

  programs = {
    dconf.enable = true;
    zsh.enable = true;
    nix-ld.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    curl
    cachix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
