{...}: {
  services.autofs = {
    enable = true;
    autoMaster = ''
      /net /etc/auto.net --timeout 3600

    '';
  };

  environment.etc = {
    "auto.net" = {
      text = ''
        Media1 -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/Media1/Media1
        Media2 -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/Media2/Media2
        Vault -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/Vault/VaultData
        TurboVault -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/TurboVault/TurboVaultData
      '';
      mode = "0644";
    };
  };
}
