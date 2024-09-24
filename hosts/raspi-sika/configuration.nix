# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  apInterface = "uap0";
  physicalInterface = "wlan0";
in {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/zsh.nix
    inputs.main-config.nixosModules.mainUser
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Networking
  networking = {
    hostName = "raspi-sika";
    wireless = {
      enable = true;
      interfaces = [physicalInterface];
      networks = {
        "schreibernet" = {
          psk = "Schreiber-wifi+";
        };
        # Add more networks as needed
      };
    };

    # dhcpcd = {
    #   enable = true;
    #   extraConfig = ''
    #     # RaspAP uap0 configuration
    #     interface ${apInterface}
    #     static ip_address=192.168.50.1/24
    #     nohook wpa_supplicant
    #   '';
    # };

    networkmanager.enable = false;

    # interfaces.${apInterface} = {
    #   ipv4.addresses = [
    #     {
    #       address = "192.168.50.1";
    #       prefixLength = 24;
    #     }
    #   ];
    # };

    # # Create a bridge for AP and client mode
    # bridges = {
    #   ${bridgeInterface} = {
    #     interfaces = [physicalInterface apInterface];
    #   };
    # };
  };

  # Create and manage the virtual AP interface
  systemd.services.setup-ap-interface = {
    description = "Setup AP Interface";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    before = ["hostapd.service" "dnsmasq.service" "dhcpcd.service" "wpa_supplicant-${physicalInterface}.service" "enable-network-services.service"];
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
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.services.enable-network-services = {
    description = "Enable network services";
    wantedBy = ["multi-user.target"];
    after = ["network.target" "setup-ap-interface.service"];
    script = ''
      #!/bin/bash
      set -e

      # Start services
      echo "Starting services"
      systemctl start hostapd.service
      systemctl start dhcpcd.service
      systemctl start dnsmasq.service
      systemctl start wpa_supplicant-${physicalInterface}.service
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Enable hostapd for the access point
  services.hostapd = {
    enable = true;
    radios.${apInterface} = {
      band = "2g";
      channel = 11;
      # countryCode = "CH";
      wifi4 = {
        enable = true;
        capabilities = ["HT20" "SHORT-GI-20"];
      };
      networks.${apInterface} = {
        ssid = "raspi-sika";
        authentication = {
          mode = "wpa3-sae-transition";
          # mode = "wpa3-sae";
          # mode = "wpa2-sha256";
          saePasswords = [
            {password = "Password123";}
          ];
          wpaPassword = "Password123";
        };
        # bssid = "d2:3a:dd:7d:02:de";
        bssid = "d8:3a:dd:7d:02:de";
        settings = {
          auth_algs = 1;
          wpa_pairwise = "CCMP";
          rsn_pairwise = "CCMP";
          ignore_broadcast_ssid = 0;
        };
      };
    };
  };

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

  # DHCP server for the hotspot network
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = ["lo" apInterface];
      bind-interfaces = true;
      dhcp-range = "192.168.50.50,192.168.50.150,24h";
      domain-needed = true;
      bogus-priv = true;
      # no-resolv = true;
      # no-hosts = true;
      server = ["1.1.1.1" "1.0.0.1"];
      # dhcp-option = [
      #   "option:router,192.168.50.1"
      #   "option:dns-server,192.168.50.1"
      # ];
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    # SSH
    22
    # DNS
    53
  ];
  networking.firewall.allowedUDPPorts = [
    # DNS
    53
    # DHCP
    67
    68
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
    settings.trusted-users = [
      "root"
      "cyril"
      "@wheel"
    ];
    settings.auto-optimise-store = true;
  };

  time.timeZone = "Europe/Zurich";

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_NUMERIC = "fr_CH.UTF-8";
    LC_TIME = "en_IE.UTF-8";
    LC_MONETARY = "fr_CH.UTF-8";
    LC_PAPER = "fr_CH.UTF-8";
    LC_NAME = "fr_CH.UTF-8";
    LC_ADDRESS = "fr_CH.UTF-8";
    LC_TELEPHONE = "fr_CH.UTF-8";
    LC_MEASUREMENT = "fr_CH.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr_CH";
  };

  mainUser = {
    enable = true;
    userName = "cyril";
    fullUserName = "Cyril";
    extraGroups = ["networkmanager" "wheels"];
    importSshKeysFromGithub = true;
  };

  security.sudo.extraRules = [
    {
      users = ["cyril"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  hardware.pulseaudio.enable = true;

  # home-manager = {
  #   extraSpecialArgs = {inherit inputs;};
  #   backupFileExtension = "backup";
  #   users = {
  #     "cyril" = import ./home.nix;
  #   };
  # };

  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    git
    tree
    python3
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = true;
    };
  };

  system.stateVersion = "24.11";
}
