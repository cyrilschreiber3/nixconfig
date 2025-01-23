{
  config,
  lib,
  ...
}: let
  cfg = config.wireguardClientConfig;
in {
  options = {
    wireguardClientConfig = {
      enable = lib.mkEnableOption "Enable WireGuard client";
      enableSchreibernet = lib.mkEnableOption "Enable Schreibernet network";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [51820];

    networking.wireguard.enable = true;
    networking.wireguard.interfaces = {
      wg0 = {
        ips = ["10.182.192.3/32"];
        listenPort = 51820;

        privateKeyFile = "/etc/wireguard-keys/private";

        peers = [
          {
            name = "Aquila-VPN-01";
            publicKey = "Wn8UaNrfnhBz4+JGXz9CKLNXK2opjAyM8AqRnknNF04=";

            # Allow all traffic
            allowedIPs = ["0.0.0.0/0"];
            # Or forward only particular subnets
            # allowedIPs = [ "10.182.192.0/24" "192.168.1.0/24" ];

            endpoint = "vpn.the127001.ch:51820";

            # Send keepalives every 25 seconds. Important to keep NAT tables alive.
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
