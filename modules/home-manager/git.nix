{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.gitConfig;

  # Home Manager 24.05+ uses 'settings', older versions use 'extraConfig'
  useNewGitConfig = lib.versionAtLeast config.home.version.release "25.11";

  defaultPinentry =
    if config.plasmaConfig.enable
    then pkgs.pinentry-qt
    else if pkgs.stdenv.isDarwin
    then pkgs.pinentry-mac
    else pkgs.pinentry-gnome3;

  gitConfigAttr =
    if useNewGitConfig
    then "settings"
    else "extraConfig";
in {
  options.gitConfig = {
    enable = lib.mkEnableOption "Enable git module";
    enableGPG = lib.mkEnableOption "Configure GPG and GPG-agent";
    mainGPGKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The GPG key to use to sign git commits";
    };
    useWindowsPinentry = lib.mkEnableOption "Use the windows pinentry program";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      ${gitConfigAttr} = {
        init = {
          defaultBranch = "master";
        };
        url = {
          "https://github.com/" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
          "https://gitlab.com/" = {
            insteadOf = [
              "gl:"
              "gitlab:"
            ];
          };
        };
        user = {
          name = "cyrilschreiber3";
          email = "contact@cyrilschreiber.ch";
          signingkey = lib.mkIf cfg.enableGPG "${cfg.mainGPGKey}";
        };
        credential.credentialStore = lib.mkIf cfg.enableGPG "gpg";
        commit.gpgsign = cfg.enableGPG;
      };
    };

    programs.gpg = {
      enable = cfg.enableGPG;
    };
    services.gpg-agent = {
      enable = cfg.enableGPG;
      enableZshIntegration = true;
      defaultCacheTtl = 28800;
      maxCacheTtl = 86400;
      pinentry.package = lib.mkIf (!cfg.useWindowsPinentry) defaultPinentry;
      extraConfig = lib.mkIf cfg.useWindowsPinentry ''
        pinentry-program "/mnt/c/Program Files (x86)/GnuPG/bin/pinentry-basic.exe"
      '';
    };
  };
}
