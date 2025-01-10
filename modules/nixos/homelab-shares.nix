{...}: {
  services.autofs = {
    enable = true;
    autoMaster = ''
      /mnt/Media1 -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/Media1/Media1
      /mnt/Media2 -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/Media2/Media2
      /mnt/Vault -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/Vault/VaultData
      /mnt/TurboVault -fstype=nfs,rw,nfsvers=4 192.168.1.10:/mnt/TurboVault/TurboVaultData
    '';
  };
}
