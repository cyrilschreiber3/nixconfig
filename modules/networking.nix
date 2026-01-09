{
  lib,
  pkgs,
  physicalInterface,
  wifiConfig,
  ...
}: {
  environment.systemPackages = with pkgs; [
    libimobiledevice # for USB tethering
  ];

  networking = {
    hostName = "raspi-sika";
    wireless = {
      enable = true;
      interfaces = [physicalInterface];
      secretsFile = "/run/secrets/wifi-passwords";
      networks =
        lib.mapAttrs (name: _: {
          pskRaw = "ext:${lib.replaceStrings [" " "’" "-" "\\"] ["_" "" "_" ""] (lib.toUpper name)}_PSK";
          priority =
            if name == "Cyril’s Phone"
            then 10
            else 1;
        })
        wifiConfig.wifi_networks;
    };

    networkmanager.enable = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        # SSH
        22
        # Siren control interface
        80
      ];
      allowedUDPPorts = [];
    };
  };

  # Enable usbmuxd for iPhone USB tethering
  services.usbmuxd = {
    enable = true;
  };
}
