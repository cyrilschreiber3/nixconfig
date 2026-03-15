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
        guiAddress = "127.0.0.1:8385";
        gui = {
          user = "cyril";
          address = "127.0.0.1:8385";
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
          scorpius-cl-01 = {
            id = "DXF3L4P-IHDSQ5S-DA6UEHM-EJUMFVT-M4AQBAO-AINMX3T-QCQ4EBL-AZWEKAU";
            addresses = ["dynamic"];
          };
          macbook = {
            id = "VNO7ST7-MH233QW-6YJ7YZN-JF5X6AL-CANMOEQ-A3WKC67-OSSXCYZ-NXGADQN";
            addresses = ["dynamic"];
          };
        };
        folders = {
          admin = {
            id = "admin";
            label = "admin";
            path = "~/Documents/Admin";
            devices = ["scorpius-cl-01" "macbook"];
          };
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
