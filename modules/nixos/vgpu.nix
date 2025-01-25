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
      virt-manager # virtual machines
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice
      adwaita-icon-theme
    ];

    services.fastapi-dls = {
      enable = true;
      debug = true;
      listen.ip = "0.0.0.0";
    };

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
    boot.extraModprobeConfig = ''
      options nvidia vfio-pci vup_sunlock=1 vup_swrlwar=1 vup_qmode=1
    '';

    services.udev.extraRules = ''
      SUBSYSTEM=="vfio", KERNEL=="vfio*", MODE="0666"
      ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x15b7", ATTR{device}=="0x5030", ATTR{power/control}="on", TEST=="power/control", ATTR{remove}="1", ATTR{path}=="*40:00.0*", DRIVER=="", RUN+="${pkgs.kmod}/bin/modprobe vfio-pci"
    '';

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.vgpu_17_3;
    hardware.nvidia.vgpu = {
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
  };
}
