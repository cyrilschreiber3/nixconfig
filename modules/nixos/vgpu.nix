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
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      looking-glass-client
      mdevctl
      virt-manager # virtual machines
      virt-viewer # needed to choose share folders with windows VM (guide and video: https://www.guyrutenberg.com/2018/10/25/sharing-a-folder-a-windows-guest-under-virt-manager/ and https://www.youtube.com/watch?v=Ow3gVbkWj-c)
      spice-gtk # for virtual machines (to connect usbs and everything else)
    ];

    services.fastapi-dls = {
      enable = true;
      debug = true;
      listen.ip = "0.0.0.0";
    };

    boot.extraModprobeConfig = ''
      options nvidia vup_sunlock=1 vup_swrlwar=1 vup_qmode=1
    ''; # (for driver 535) bypasses `error: vmiop_log: NVOS status 0x1` in nvidia-vgpu-mgr.service when starting VM
    boot.kernelModules = ["nvidia-vgpu-vfio"];
    # boot.kernelPackages = pkgs.linuxPackages_6_1; # needed, 6.1 is LTS
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.vgpu_17_3;
    hardware.nvidia.vgpu = {
      patcher = {
        enable = true;
        options = {
          remapP40ProfilesToV100D = true; # for 17_x
        };
        copyVGPUProfiles = {
          "1f54:0000" = "1E30:12BA"; # RTX 2060 Mobile 6GB (is already supported in the repo)
        };
      };
      driverSource = {
        name = "NVIDIA-GRID-Linux-KVM-550.90.05-550.90.07-552.74.zip";
        url = "http://cdn.the127001.ch/config/nixos/NVIDIA-GRID-Linux-KVM-550.90.05-550.90.07-552.74.zip";
      };
    };

    users.users.${cfg.mainUser}.extraGroups = ["libvirtd"];
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true; # to enable USB rederection in virt-manager (https://github.com/NixOS/nixpkgs/issues/106594)
  };
}
