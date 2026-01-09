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
    inputs.sops-nix.homeManagerModules.sops
  ];

  options.sopsConfig = {
    enable = lib.mkEnableOption "Enable sops support";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      sops
      age
    ];

    sops = {
      defaultSopsFile = "${inputs.self.outPath}/secrets/secrets.yaml";
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  };
}
