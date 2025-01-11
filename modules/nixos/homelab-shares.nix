{pkgs, ...}: {
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
      text = ''
        /mnt/Media1 -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/Media1/Media1
        /mnt/Media2 -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/Media2/Media2
        /mnt/Vault -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/Vault/VaultData
        /mnt/TurboVault -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/TurboVault/TurboVaultData
      '';
      mode = "0644";
    };
  };
}
