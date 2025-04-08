# most of this is copied from https://github.com/Yeshey/nixOS-Config/blob/36b521712fb45c7b65f6c8f409af127acc8a35f5/nixos/hyrulecastle/vgpu.nix
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.vGPUVMConfig;
in {
  imports = [
    inputs.vgpu4nixos.nixosModules.host
    inputs.fastapi-dls-nixos.nixosModules.default
  ];

  options = {
    vGPUVMConfig = {
      enable = lib.mkEnableOption "Enable vGPU VM";
      mainUser = lib.mkOption {
        type = lib.types.str;
        description = "The main user of the system";
      };
      cpuType = lib.mkOption {
        description = "One of `intel` or `amd`";
        default = "intel";
        type = lib.types.str;
      };

      pciIDs = lib.mkOption {
        description = "Comma-separated list of PCI IDs to pass-through (lspci -nn)";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      looking-glass-client
      mdevctl
      pciutils
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice
      adwaita-icon-theme
      parsec-bin
      cifs-utils
      (pkgs.writeShellScriptBin "merlin-cl-06-init" (builtins.readFile ./../bin/startMerlin.sh))
      (pkgs.makeDesktopItem {
        name = "merlin-cl-06-init";
        desktopName = "Start Merlin-CL-06";
        comment = "Start the Merlin-CL-06 VM and launch Looking Glass.";
        exec = "merlin-cl-06-init";
        icon = "utilities-terminal";
        terminal = false;
        categories = ["Utility" "System"];
        genericName = "Virtual Machine Display";
      })
    ];

    services.fastapi-dls = {
      enable = true;
      debug = true;
      listen.ip = "0.0.0.0";
    };
    networking.firewall.interfaces.virbr0.allowedTCPPorts = [443];

    boot.kernelParams = [
      "${cfg.cpuType}_iommu=on"
      "kvm.ignore_msrs=1"
      "iommu=pt"
    ];
    boot.kernelModules = [
      "vfio"
      "vfio_iommu_type1"
      "vfio_pci"
      "vfio_virqfd"
      "nvidia-vgpu-vfio"
    ];
    # TODO: check https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html for passthrough
    boot.extraModprobeConfig = ''
      options nvidia vup_sunlock=1 vup_swrlwar=1 vup_qmode=1

      blacklist i2c_nvidia_gpu
    '';

    services.udev.extraRules = ''
      SUBSYSTEM=="block", ATTRS{serial}=="24434Y4A1N09", MODE="0660", GROUP="libvirtd"
    '';

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${cfg.mainUser} libvirtd -"
    ];

    boot.kernelPackages = pkgs.linuxPackages_6_6;

    hardware.nvidia.package = lib.mkIf (config.specialisation != {}) config.boot.kernelPackages.nvidiaPackages.vgpu_17_3;
    hardware.nvidia.vgpu = lib.mkIf (config.specialisation != {}) {
      patcher = {
        enable = true;
        options = {
          remapP40ProfilesToV100D = true; # for 17_x
        };
        copyVGPUProfiles = {
          "1f54:0000" = "1E30:12BA";
        };
      };
      driverSource = {
        name = "NVIDIA-GRID-Linux-KVM-550.90.05-550.90.07-552.74.zip";
        url = "http://cdn.the127001.ch/config/nixos/NVIDIA-GRID-Linux-KVM-550.90.05-550.90.07-552.74.zip";
      };
    };
    # hardware.nvidia.open = true;

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        libva
        libva-utils
        libva-vdpau-driver
        mesa
      ];
    };

    # VM configuration

    users.users.${cfg.mainUser}.extraGroups = ["libvirtd" "kvm"];
    virtualisation = {
      libvirtd = {
        enable = true;

        qemu = {
          package = pkgs.qemu_kvm;
          ovmf = {
            enable = true;
            packages = [pkgs.OVMFFull.fd];
          };
          swtpm.enable = true;
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;

    environment.etc = let
      hooksPath = "libvirt/hooks/qemu.d";
    in {
      "${hooksPath}/Merlin-CL-06/prepare/begin/start.sh" .source = "${./../dotfiles/libvirt/Merlin-CL-06/prepare/begin/start.sh}";
      "${hooksPath}/Merlin-CL-06/release/end/revert.sh" .source = "${./../dotfiles/libvirt/Merlin-CL-06/release/end/revert.sh}";
    };
  };
}
