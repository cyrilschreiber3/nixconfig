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
      guiAddress = "127.0.0.1:8385";
      settings = {
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
          mercury-fs-01 = {
            id = "FJ6CB6Q-6GVVWFE-IPDNXKI-4H7KFPI-ZPTJPSM-PIIGFOQ-QMDNEHA-2BD7KA2";
            addresses = ["dynamic"];
          };
        };
        folders = {
          admin = {
            id = "admin";
            label = "admin";
            path = "~/Documents/admin";
            devices = ["scorpius-cl-01" "mercury-fs-01" "macbook"];
          };
          pompiers = {
            id = "pompiers";
            label = "pompiers";
            path = "~/Documents/pompiers";
            devices = ["scorpius-cl-01" "mercury-fs-01" "macbook"];
          };
        };
      };
    };
  };
}
