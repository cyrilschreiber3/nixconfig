{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.mainUser;
in {
  options.mainUser = {
    enable = lib.mkEnableOption "enable user module";
    userName = lib.mkOption {
      default = "mainuser";
      description = ''
        username
      '';
    };
    fullUserName = lib.mkOption {
      default = "main user";
      description = ''
        full username
      '';
    };
    extraGroups = lib.mkOption {
      default = ["networkmanager"];
      description = ''
        extra user groups
      '';
    };
    importSshKeysFromGithub = lib.mkEnableOption "Import SSH public keys from Github";
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      initialPassword = cfg.userName;
      description = cfg.fullUserName;
      extraGroups = cfg.extraGroups;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keyFiles = lib.mkIf cfg.importSshKeysFromGithub [inputs.ssh-keys.outPath];
    };
  };
}
