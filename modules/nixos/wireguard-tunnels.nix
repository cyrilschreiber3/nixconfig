{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.wireguardTunnels;

  wireguardTunnels = lib.flatten [
    {
      name = "Polylan-01";
      server = "62.220.133.87";
      port = "52025";
      publicKey = "laiD0e9/1pQJox0b04RAIxsikWYAvyEeof5karsziHE=";
      allowedips = "10.192.0.0/16";
      address = "10.192.250.10/27";
      dns = null;
      wg-tray = {
        topLevel = false;
        groups = ["Polylan"];
      };
    }
    {
      name = "Polylan-02";
      server = "62.220.133.88";
      port = "52025";
      publicKey = "IAa2BW644sot40N/KP6FqNV1joC69S/HQrQziymCNVk=";
      allowedips = "10.192.0.0/16";
      address = "10.192.250.42/27";
      dns = null;
      wg-tray = {
        topLevel = false;
        groups = ["Polylan"];
      };
    }
    {
      name = "Polylan-03";
      server = "62.220.133.89";
      port = "52025";
      publicKey = "GpFb6KEaXJlD0LnSmAo/BZM8PqG7S1Kau7/BWd9qb1Y=";
      allowedips = "10.192.0.0/16";
      address = "10.192.250.47/27";
      dns = null;
      wg-tray = {
        topLevel = false;
        groups = ["Polylan"];
      };
    }
  ];

  wireguardTunnelsSecrets = pkgs.copyPathToStore ./../dotfiles/wireguard/TunnelsSecrets.yaml;

  decryptSecret = secret: tunnelName: ''su ${cfg.gpgUser} -c "sops decrypt --extract '[\"wireguardTunnels\"][\"${tunnelName}\"][\"${secret}\"]' ${wireguardTunnelsSecrets}"'';

  wireguardTunnelTemplate = tunnel: ''
    [Interface]
    PostUp = wg set %i private-key <(${decryptSecret "PrivateKey" tunnel.name})
    PostUp = wg set %i peer ${tunnel.publicKey} preshared-key <(${decryptSecret "PresharedKey" tunnel.name})
    ListenPort = ${tunnel.port}
    Address = ${tunnel.address}
    ${
      if (tunnel.dns != null)
      then "DNS = ${tunnel.dns}"
      else ""
    }
    [Peer]
    PublicKey = ${tunnel.publicKey}
    Endpoint = ${tunnel.server}:${tunnel.port}
    AllowedIps = ${tunnel.allowedips}
  '';
in {
  options.wireguardTunnels = {
    enable = lib.mkEnableOption "Enable Wireguard Tunnels module";
    gpgUser = lib.mkOption {
      type = lib.types.str;
      default = "cyril";
      description = "GPG user to use for decrypting Wireguard keys";
    };
    wgTrayGoConfig = lib.mkOption {
      type = lib.types.attrs;
      description = "WG Tray Go configuration for Wireguard tunnels";
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = builtins.listToAttrs (
      map (tunnel: {
        name = "wireguard/${tunnel.name}.conf";
        value =
          {
            text = wireguardTunnelTemplate tunnel;
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            mode = "0600";
          };
      })
      wireguardTunnels
    );

    wireguardTunnels.wgTrayGoConfig = {
      tunnelNames = map (t: t.name) (lib.filter (t: t.wg-tray.topLevel) wireguardTunnels);
      tunnelGroups = let
        allGroups = lib.unique (lib.concatLists (map (t: t.wg-tray.groups) wireguardTunnels));
      in
        map (groupName: {
          name = groupName;
          pickRandomly = true;
          tunnelNames = map (t: t.name) (lib.filter (t: lib.elem groupName t.wg-tray.groups) wireguardTunnels);
        })
        allGroups;
    };
  };
}
