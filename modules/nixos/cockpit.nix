{pkgs, ...}: {
  services.cockpit = {
    enable = true;
    package = pkgs.cockpit;
    port = 9090;
    openFirewall = true;
    settings = {};
  };
}
