{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.autofsConfig;

  # Define default shares
  defaultShares = {
    media1 = {
      mountPoint = "/mnt/Media1";
      server = "10.1.1.20";
      serverPath = "/mnt/Media1/Media1";
      mountOptions = "-fstype=nfs,rw,nfsvers=4";
      description = "First media share";
    };
    media2 = {
      mountPoint = "/mnt/Media2";
      server = "10.1.1.20";
      serverPath = "/mnt/Media2/Media2";
      mountOptions = "-fstype=nfs,rw,nfsvers=4";
      description = "Second media share";
    };
    vault = {
      mountPoint = "/mnt/Vault";
      server = "10.1.1.20";
      serverPath = "/mnt/Vault/VaultData";
      mountOptions = "-fstype=nfs,rw,nfsvers=4";
      description = "Vault storage";
    };
    turboVault = {
      mountPoint = "/mnt/TurboVault";
      server = "10.1.1.20";
      serverPath = "/mnt/TurboVault/TurboVaultData";
      mountOptions = "-fstype=nfs,rw,nfsvers=4";
      description = "High-speed vault storage";
    };
  };

  # Share type definition
  shareType = lib.types.submodule {
    options = {
      mountPoint = lib.mkOption {
        type = lib.types.str;
        description = "Local mount point path";
      };

      server = lib.mkOption {
        type = lib.types.str;
        description = "NFS server IP or hostname";
      };

      serverPath = lib.mkOption {
        type = lib.types.str;
        description = "Remote path on NFS server";
      };

      mountOptions = lib.mkOption {
        type = lib.types.str;
        default = "-fstype=nfs,rw,nfsvers=4";
        description = "Mount options for the NFS share";
        example = "-fstype=nfs,rw,nfsvers=4,soft,retry=0";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Description of the share purpose";
      };
    };
  };

  # Helper function to format a share entry
  formatShare = share: ''
    ${share.mountPoint} ${share.mountOptions} ${share.server}:${share.serverPath}
  '';

  # Get enabled default shares
  enabledDefaultShares =
    lib.filterAttrs
    (name: _: builtins.elem name cfg.enabledDefaultShares)
    defaultShares;

  # Combine enabled default shares with custom shares
  allShares = (builtins.attrValues enabledDefaultShares) ++ cfg.customShares;
in {
  options.autofsConfig = {
    enable = lib.mkEnableOption "Enable AutoFS module";

    enabledDefaultShares = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames defaultShares));
      default = [];
      description = "List of default shares to enable";
      example = ["media1" "vault"];
    };

    customShares = lib.mkOption {
      type = lib.types.listOf shareType;
      default = [];
      description = "List of custom NFS shares to mount";
      example = lib.literalExpression ''
        [
          {
            mountPoint = "/mnt/CustomShare";
            server = "192.168.1.20";
            serverPath = "/exports/data";
            mountOptions = "-fstype=nfs,rw,nfsvers=4,soft";
            description = "Custom data share";
          }
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [nfs-utils];
    boot.supportedFilesystems = ["nfs"];
    boot.kernelModules = ["nfs" "autofs"];

    services.autofs = {
      enable = true;
      autoMaster = let
        mapConf = ''
          /- /etc/auto.direct --timeout 3600
        '';
      in ''
        ${mapConf}
      '';
    };

    environment.etc = {
      "autofs.conf" = {
        text = ''
          [ autofs ]
          timeout=300
          browse_mode=no
          mount_nfs_default_protocol=4
          [ amd ]
          dismount_interval=300
        '';
        mode = "0644";
      };
      "auto.direct" = {
        text = lib.concatMapStrings formatShare allShares;
        mode = "0644";
      };
    };
  };
}
