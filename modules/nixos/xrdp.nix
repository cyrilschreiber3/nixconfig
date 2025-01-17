{...}: {
  services.xrdp = {
    enable = true;
    audio.enable = true;
    openFirewall = true;
  };
}
