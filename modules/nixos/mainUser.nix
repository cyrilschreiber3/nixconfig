{
  pkgs,
  lib,
  config,
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
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      initialPassword = cfg.userName;
      description = cfg.fullUserName;
      extraGroups = cfg.extraGroups;
      shell = pkgs.zsh;
    };
  };
}
