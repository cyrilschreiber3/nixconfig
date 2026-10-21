{lib, ...}: {
  specialisation."vgpu".configuration = {
    environment.sessionVariables.SPECIALISATION = lib.mkForce "vgpu";
    system.nixos.tags = ["vgpu"];

    vGPUVMConfig.active = true;
  };
}
