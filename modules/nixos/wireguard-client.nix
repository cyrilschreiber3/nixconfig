{
  config,
  lib,
  pkgs,
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
        ips = ["10.182.192.3/24"];
        listenPort = 51820;

        postSetup = ''
          ENDPOINT_IP=$(wg show wg0 endpoints | awk '{print $2}' | cut -d':' -f1)
          DEFAULT_ROUTE=$(${pkgs.iproute2}/bin/ip route | grep '^default' | grep -v 'docker\|veth\|br-')
          GW="$(echo $DEFAULT_ROUTE | awk '{print $3}' | head -n 1)"
          DEV="$(echo $DEFAULT_ROUTE | awk '{print $5}' | head -n 1)"
          ${pkgs.iproute2}/bin/ip route add $ENDPOINT_IP via $GW dev $DEV
        '';

        privateKeyFile = "/etc/wireguard-keys/private";

        peers = [
          {
            name = "Aquila-VPN-01";
            publicKey = "Wn8UaNrfnhBz4+JGXz9CKLNXK2opjAyM8AqRnknNF04=";
            presharedKeyFile = "/etc/wireguard-keys/pre-shared-schreibernet";

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
