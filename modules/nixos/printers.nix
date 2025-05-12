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
      epsonscan2
    ];

    # Enable CUPS to print documents.
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
