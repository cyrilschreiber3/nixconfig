{
  pkgs,
  apInterface,
  physicalInterface,
  ...
}: {
  # Configure NAT
  networking.nat = {
    enable = true;
    externalInterface = physicalInterface;
    internalInterfaces = [apInterface];
  };

  # Enable IP forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  # Create and manage the virtual AP interface
  systemd.services.setup-ap-interface = {
    description = "Setup AP Interface";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    before = ["enable-network-services.service"];
    path = [pkgs.iproute2 pkgs.iw];
    script = ''
      #!/bin/bash
      set -e

      # Remove existing uap0 interface if it exists
      if ${pkgs.iproute2}/bin/ip link show ${apInterface} &>/dev/null; then
        echo "${apInterface} interface exists. Removing it."
        ${pkgs.iw}/bin/iw dev ${apInterface} del || true
      else
        echo "${apInterface} interface does not exist. Proceeding with creation."
      fi

      # Ensure services are stopped
      echo "Stopping services"
      systemctl stop hostapd.service
      systemctl stop dnsmasq.service
      systemctl stop dhcpcd.service
      systemctl stop wpa_supplicant-${physicalInterface}.service

      # Create uap0 interface
      echo "Creating ${apInterface} interface..."
      ${pkgs.iw}/bin/iw dev ${physicalInterface} interface add ${apInterface} type __ap

      # Set up the interface
      echo "Setting up ${apInterface} interface..."
      ${pkgs.iproute2}/bin/ip addr add 192.168.50.1/24 dev ${apInterface}
      ${pkgs.unixtools.ifconfig}/bin/ifconfig ${apInterface} up

      # Wait for interface to be fully operational
      echo "Waiting for ${apInterface} to be active..."
      for i in {1..30}; do
        if systemctl is-active --quiet sys-subsystem-net-devices-${apInterface}.device; then
          echo "${apInterface} is up and running"
          sleep 2  # Extra delay to ensure kernel is ready
          break
        fi
        if [ $i -eq 30 ]; then
          echo "ERROR: ${apInterface} failed to come up after 30 seconds"
          exit 1
        fi
        echo "Waiting... ($i/30)"
        sleep 1
      done
      echo "${apInterface} is ready for hostapd"

      # Start services
      echo "Starting services"
      systemctl restart hostapd.service
      systemctl restart dhcpcd.service
      systemctl restart dnsmasq.service
      systemctl restart wpa_supplicant-${physicalInterface}.service
    '';
    postStart = "${pkgs.writeShellScript "led-status.sh" ''
      #!/bin/bash
      # Inspiration: https://forums.raspberrypi.com/viewtopic.php?t=12530#p136266
      echo "Setup AP interface completed, updating LED status..."

      # Reset default led triggers
      echo none >/sys/class/leds/ACT/trigger
      echo none >/sys/class/leds/default-on/trigger
      echo none >/sys/class/leds/mmc0/trigger

      # Check if main script succeeded and bar-sika is running
      if systemctl is-active --quiet bar-sika.service; then
        echo "bar-sika and network are running. Setting LED to heartbeat."
        echo heartbeat >/sys/class/leds/ACT/trigger
      else
        echo "bar-sika service is not running. Setting LED to blinking."
        echo timer >/sys/class/leds/ACT/trigger
      fi
    ''}";
    onFailure = ["setup-ap-interface-failed.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.services.setup-ap-interface-failed = {
    description = "Handle failed AP Interface setup";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      #!/bin/bash
      set -e

      echo "Setup AP interface failed, setting LED to blinking."

      # Reset default led triggers
      echo none >/sys/class/leds/ACT/trigger
      echo none >/sys/class/leds/default-on/trigger
      echo none >/sys/class/leds/mmc0/trigger

      echo timer >/sys/class/leds/ACT/trigger
    '';
  };

  # Enable hostapd for the access point
  services.hostapd = {
    enable = true;
    radios.${apInterface} = {
      band = "2g";
      channel = 11;
      countryCode = "CH";
      wifi4 = {
        enable = true;
        capabilities = ["HT20" "SHORT-GI-20"];
      };
      wifi5.enable = false;
      wifi6.enable = false;
      wifi7.enable = false;
      networks.${apInterface} = {
        ssid = "raspi-sika";
        authentication = {
          mode = "wpa2-sha256";
          wpaPassword = "Sika-118";
        };
        bssid = "d2:3a:dd:7d:02:de";
        settings = {
          auth_algs = 1;
          wpa_pairwise = "CCMP";
          rsn_pairwise = "CCMP";
          ignore_broadcast_ssid = 0;
        };
      };
    };
  };

  # DHCP server for the hotspot network
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = apInterface;
      bind-interfaces = true;
      dhcp-range = "192.168.50.50,192.168.50.150,24h";
      domain-needed = true;
      bogus-priv = true;
      server = ["1.1.1.1" "1.0.0.1"];
      dhcp-option = [
        "option:router,192.168.50.1"
        "option:dns-server,192.168.50.1"
      ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # DNS
      53
    ];
    allowedUDPPorts = [
      # DNS
      53
      # DHCP
      67
      68
    ];
    extraCommands = ''
      iptables -t nat -A POSTROUTING -o ${physicalInterface} -j MASQUERADE
      iptables -A FORWARD -i ${apInterface} -o ${physicalInterface} -j ACCEPT
      iptables -A FORWARD -i ${physicalInterface} -o ${apInterface} -m state --state RELATED,ESTABLISHED -j ACCEPT
      iptables -t nat -A POSTROUTING -o ${physicalInterface} -j MASQUERADE
      iptables -t nat -A POSTROUTING -s 192.168.50.0/24 ! -d 192.168.50.0/24 -j MASQUERADE
    '';
  };
}
