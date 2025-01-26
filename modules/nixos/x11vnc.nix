# temporary, source: https://github.com/pareshmg/nixos-config/blob/f8ed5da91ff68bc868ac63ae79b7010481e1e638/modules/desktop/virtualisation/x11vnc.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.x11vncConfig;
in {
  options.x11vncConfig = {
    enable = lib.mkEnableOption "Enable x11vnc module";
    mainUser = lib.mkOption {
      type = lib.types.str;
      default = "cyril";
      description = "The main user of the system";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [5900];

    environment = {
      # VNC used for remote access to the desktop
      systemPackages = with pkgs; [
        x11vnc
      ];
    };

    systemd.services."x11vnc" = {
      enable = true;
      description = "VNC Server for X11";
      requires = ["display-manager.service"];
      after = ["display-manager.service"];
      serviceConfig = {
        # Password is stored in document passwd at $HOME. This needs auth and link to display. Otherwise x11vnc won't detect the display
        ExecStart = "${pkgs.x11vnc}/bin/x11vnc -passwdfile /home/${cfg.mainUser}/passwd -rfbport 5566 -rfbportv6 5566 -noxdamage -nap -many -repeat -clear_keys -capslock -xkb -forever -loop100 -auth /var/run/lightdm/root/:0 -display :0";
        ExecStop = "${pkgs.x11vnc}/bin/x11vnc -R stop";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
