{
  pkgs,
  mypkgs,
  mypkgs-2405,
  ...
}: {
  imports = [
    ./../../modules/home-manager
    # ./../../modules/home-manager/gnome.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "cyril";
  home.homeDirectory = "/home/cyril";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      # media
      ffmpeg
      yt-dlp
      vlc
      gimp
      obs-studio
      kdePackages.kdenlive
      darktable
      figma-linux

      # work
      onlyoffice-desktopeditors
      xreader

      # voip
      discord

      # gaming
      # steam
      # lutris
      # winetricks
      # flatpak

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
      powershell
      speedtest-cli

      # dev
      nixd
      alejandra
      nixpkgs-fmt
      nodejs
      python3

      # docker
      docker
      #nvidia-container-toolkit

      # browsers
      chromium
      google-chrome
      brave

      # virtualization / emulation

      # formatting
      gparted
      exfatprogs
      xfsprogs
      btrfs-progs

      # misc
      obsidian

      (writeShellScriptBin "rebuild" (builtins.readFile ./../../modules/bin/rebuild.sh))
    ]
    ++ [
      # mypkgs.example-package
      mypkgs-2405.yuzu
    ];

  mimeApps = {
    enable = true;
    defaultApps = {
      browser = "firefox.desktop";
      textEditor = "org.x.editor.desktop";
      imageViewer = "pix.desktop";
      documentViewer = "xreader.desktop";
      documentEditor = "onlyoffice-desktopeditors.desktop";
    };
  };

  # ------------------------ #
  # --- Programs configs --- #
  # ------------------------ #

  btopConfig.enable = true;

  cinnamonConfig = {
    enable = true;
    enableSharesBookmarks = true;
  };

  firefoxConfig.enable = true;

  gitConfig = {
    enable = true;
    enableGPG = true;
    mainGPGKey = "43FF705A6EDF1601";
    useWindowsPinentry = false;
  };

  remminaConfig.enable = true;

  spotifyConfig = {
    enable = true;
    enableSpicetify = true;
  };

  vscodeConfig = {
    enable = true;
    enableBaseExtensions = true;
    enableLanguageExtensions = true;
  };

  zshConfig = {
    enable = true;
    enableCinnamonDE = true;
    useLegacyP10k = false;
  };

  # --------------------- #
  # --- Games configs --- #
  # --------------------- #

  missionChiefConfig.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/cyril/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  fonts.fontconfig.enable = true;

  # DO NOT CHANGE
  programs.home-manager.enable = true;
}
