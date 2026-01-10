{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.sopsConfig;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.sopsConfig = {
    enable = lib.mkEnableOption "Enable sops support";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
      age
    ];

    sops = {
      defaultSopsFile = "${inputs.self.outPath}/secrets/secrets.yaml";
      defaultSopsFormat = "yaml";

      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      secrets = {};
    };
  };
}
