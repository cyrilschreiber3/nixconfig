{
  lib,
  pkgs,
  ...
}: {
  specialisation."gaming".configuration = {
    environment.sessionVariables = lib.mkDefault {
      SPECIALISATION = "gaming";
    };
    system.nixos.tags = [
      "gaming"
    ];

    services.xserver.screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
    '';

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    boot.kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia-drm.modeset=1"
    ];
    hardware = {
      nvidia = {
        open = true;
        # package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      graphics = {
        enable = true;
        # enable32bit = true;
      };
    };
  };
}
