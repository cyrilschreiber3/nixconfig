{...}: {
  xServerConfig = {
    enable = true;
    displayManager = "lightdm";
    desktopManager = "cinnamon";
    theme = "tokyonight";
  };

  waylandConfig = {
    enable = false;
    desktopManager = "hyprland";
    # displayManager = "lightdm";
  };

  services.logind.settings.Login = {
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitch = "ignore";
  };

  services.upower.ignoreLid = true;

  services.xserver.xkb = {
    layout = "ch";
    variant = "fr";
  };
  services.libinput.enable = true;

  # Configure console keymap
  console.keyMap = "fr_CH";
}
