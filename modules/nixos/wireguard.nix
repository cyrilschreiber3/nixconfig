{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.firewall.allowedUDPPorts = [51820];

  networking.nat.enable = true;
  networking.nat.externalInterface = "enu1u1u1";
  networking.nat.internalInterfaces = ["wg0"];

  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.182.192.1/24"];
      listenPort = 51820;

      postSetup = ''${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.182.192.1/24 -o eth0 -j MASQUERADE'';
      postShutdown = ''${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.182.192.1/24 -o eth0 -j MASQUERADE'';

      # wg genkey > ~/wireguard-keys/private
      # wg pubkey < ~/wireguard-keys/private > ~/wireguard-keys/public
      # wg genpsk > ~/wireguard-keys/pre-shared-<client-name>
      privateKeyFile = "/home/admin/wireguard-keys/private";

      peers = [
        {
          name = "Cyrils-Phone";
          publicKey = "s79kW1cCzD7f9hJGTLvcZImcKE2N3R/qeuCzPDRrYBw=";
          presharedKeyFile = "/home/admin/wireguard-keys/pre-shared-cyrils-phone";
          allowedIPs = ["10.182.192.2/32"];
        }
      ];
    };
  };
}
