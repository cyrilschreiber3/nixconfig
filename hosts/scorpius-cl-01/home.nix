{
  pkgs,
  inputs,
  config,
  ...
}: let
  mypkgs = inputs.mypkgs.packages.${pkgs.system};
in {
  imports = [
    ./../../modules/home-manager/btop.nix
    ./../../modules/home-manager/git.nix
    # ./../../modules/home-manager/gnome.nix
    ./../../modules/home-manager/cinnamon.nix
    ./../../modules/home-manager/vscode.nix
    ./../../modules/home-manager/firefox.nix
    ./../../modules/home-manager/zsh.nix
    ./../../modules/home-manager/spotify.nix
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
    ffmpeg
    yt-dlp
    vlc
    gimp
    obs-studio
    kdenlive

    #voip
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

    # dev
    nil
    alejandra
    nixpkgs-fmt
    nodejs
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    bun
    python3

    # docker
    docker
    #nvidia-container-toolkit

    # browsers
    chromium
    brave

    # virtualization / emulation

    (writeShellScriptBin "rebuild" (builtins.readFile ./../../modules/bin/rebuild.sh))
    # ]
    # ++ [
    #   mypkgs.yuzu
  ];

  xdg.desktopEntries = {
    mission-chief = {
      name = "Opérateur 112";
      genericName = "Video Game";
      icon = "${pkgs.copyPathToStore ./../../modules/assets/mission-chief-icon.jpg}";
      exec = "chromium --app=https://www.operateur112.fr/ --disable-glsl-translator --start-maximized";
      terminal = false;
      categories = ["Game"];
    };
  };

  fonts.fontconfig.enable = true;

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

  gitConfig = {
    enable = true;
    enableGPG = true;
    useWindowsPinentry = false;
  };

  zshConfig = {
    enable = true;
    enableCinnamonDE = true;
    useLegacyP10k = false;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
