{lib, ...}: {
  specialisation."gaming".configuration = {
    environment.sessionVariables = lib.mkDefault {
      SPECIALISATION = "gaming";
    };
    system.nixos.tags = [
      "gaming"
    ];
  };
}
