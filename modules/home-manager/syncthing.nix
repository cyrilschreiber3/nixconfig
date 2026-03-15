{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.syncthingConfig;
in {
  options.syncthingConfig = {
    enable = lib.mkEnableOption "Enable Syncthing module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      syncthing
    ];

    sops.secrets.syncthingUIPasswd = {
      format = "yaml";
      sopsFile = "${pkgs.copyPathToStore ./../../secrets/syncthing.yaml}";
      key = "syncthingUIPasswd";
      mode = "0440";
    };

    services.syncthing = {
      enable = true;
      passwordFile = config.sops.secrets.syncthingUIPasswd.path;
      settings = {
        gui = {
          user = "cyril";
          sendBasicAuthPrompt = true;
        };
        options = {
          minHomeDiskFree = {
            unit = "%";
            value = 10;
          };
          urAccepted = -1;
        };
        defaults = {
          ignores.line = [
            "(?d).DS_Store"
          ];
        };
        devices = {
          # desktop = {
          #   id = "LFOIYQH-XC2G2JD-K43ZTWW-OBUGWUM-3NUZKOD-5M6NGWI-UKVBWM4-7WIXSAW";
          #   addresses = ["dynamic"];
          # };
          # macbook = {
          #   id = "ADWFG42-2KLFZIM-UATQGZX-AEZORQQ-MGUH4I7-INANQ6S-TG2ZUIM-WGIRUQX";
          #   addresses = ["dynamic"];
          # };
        };
        folders = {
          # admin = {
          #   id = "admin";
          #   label = "admin";
          #   path = "~/Documents/Admin";
          #   devices = ["desktop" "macbook"];
          # };
          # obsidian = {
          #   id = "obsidian";
          #   label = "obsidian";
          #   path = "~/Documents/Obsidian";
          #   devices = ["desktop" "macbook"];
          # };
        };
      };
    };
  };
}
