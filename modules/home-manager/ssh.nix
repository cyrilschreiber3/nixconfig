{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.sshConfig;
in {
  options.sshConfig = {
    enable = lib.mkEnableOption "Enable SSH module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      lib.flatten [
        []
        (lib.optional stdenv.isLinux [
          keychain
        ])
      ];

    zshConfig.enable = true;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        # Defaults
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";

        extraOptions.StrictHostKeyChecking = "accept-new";
      };
      matchBlocks."access-*" = {
        host = "access-*";
        user = "admin";
        extraOptions = {
          Ciphers = "aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc";
          MACs = "hmac-md5,hmac-sha1,umac-64@openssh.com";
          HostKeyAlgorithms = "+ssh-rsa";
          KexAlgorithms = "+diffie-hellman-group1-sha1";
          StrictHostKeyChecking = "accept-new";
        };
      };
      matchBlocks."10.0.42.*" = {
        host = "10.0.42.*";
        user = "admin";
        extraOptions = {
          Ciphers = "aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc";
          MACs = "hmac-md5,hmac-sha1,umac-64@openssh.com";
          HostKeyAlgorithms = "+ssh-rsa";
          KexAlgorithms = "+diffie-hellman-group1-sha1";
        };
      };
      matchBlocks."distrib-*" = {
        host = "distrib-*";
        user = "admin";
      };
      matchBlocks."*.polylan-infra.ch" = {
        host = "*.polylan-infra.ch";
        user = "CYRILpasMP4";
      };
    };
  };
}
