{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia-drm.modeset=1"
  ];
  hardware = {
    nvidia = {
      open = true;
    };
    graphics = {
      enable = true;
    };
  };
}
