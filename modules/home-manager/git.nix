{
  lib,
  config,
  ...
}: let
  cfg = config.gitConfig;
in {
  options.gitConfig = {
    enable = lib.mkEnableOption "Enable git module";
    enableGPG = lib.mkEnableOption "Configure GPG and GPG-agent";
    useWindowsPinentry = lib.mkEnableOption "Use the windows pinentry program";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      extraConfig = {
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
          signingkey = lib.mkIf cfg.enableGPG "5097F4EAD1ED36FBA303EC32CBE8D1DB418EB0DB";
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
      extraConfig = lib.mkIf cfg.useWindowsPinentry ''
        pinentry-program "/mnt/c/Program Files (x86)/GnuPG/bin/pinentry-basic.exe"
      '';
    };
  };
}
