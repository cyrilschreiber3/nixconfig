{
  config,
  inputs,
  lib,
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./../../modules/home-manager
  ];

  nixpkgs.overlays = [
    outputs.overlays.stable-packages
    outputs.overlays.my-packages
    outputs.overlays.my-packages-2405
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
  home.packages = with pkgs; [
    # media
    ffmpeg-full
    yt-dlp
    vlc
    gimp
    obs-studio
    kdePackages.kdenlive
    darktable
    figma-linux
    davinci-resolve-studio

    # work
    onlyoffice-desktopeditors
    xreader

    # voip
    discord
    legcord

    # gaming
    # steam
    # lutris
    # winetricks
    # flatpak
    mypkgs-2405.yuzu

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
    bruno
    yaak

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
    postman
    bitwarden
    onedrive
    onedrivegui
    onedriver

    (writeShellScriptBin "rebuild" (builtins.readFile ./../../modules/bin/rebuild.sh))
    # ]
    # ++ [
    #   # mypkgs.example-package
    #   pkgs.mypkgs-2405.yuzu
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

  xdg.desktopEntries.editConfig = lib.mkIf (config.vscodeConfig.enable) {
    name = "Edit configuration";
    comment = "Edit your nixos configuration";
    genericName = "Settings";
    icon = "${pkgs.whitesur-icon-theme}/share/icons/WhiteSur-dark/preferences/32/preferences-web-browser-stylesheets.svg";
    exec = "${pkgs.writeShellScript "editConfig" ''
      code ~/nixconfig
    ''}";
    terminal = false;
    categories = ["Development" "Settings" "System"];
  };

  # FIXME: desktop entry not showing in menu
  xdg.desktopEntries.davinci-resolve = {
    name = "Davinci Resolve Studio";
    comment = "Professional video editing, color, effects and audio post-processing";
    genericName = "Video Editor";
    icon = "davinci-resolve-studio";
    exec = "__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia davinci-resolve-studio";
    terminal = false;
    categories = ["AudioVideo" "AudioVideoEditing" "Video" "Graphics"];
  };

  xdg.configFile = {
    "autostart/OneDriveGUI.desktop".source = "${pkgs.onedrivegui}/share/applications/OneDriveGUI.desktop";
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

  starCitizenConfig = {
    enable = true;
    installPackage = true;
    package = inputs.nix-citizen.packages.${pkgs.system}.star-citizen-git;
  };

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
