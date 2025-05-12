{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.printersConfig;
in {
  options.printersConfig = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable printer support";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sane-airscan
      sane-backends
      sane-frontends
      xsane
      epson-escpr2
      (epsonscan2.override {withNonFreePlugins = true;})
    ];

    hardware.sane.extraBackends = [
      pkgs.epsonscan2
    ];

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        epson-escpr2
      ];
    };
    # Printer autodiscovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
