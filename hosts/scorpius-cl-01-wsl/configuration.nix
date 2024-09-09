{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
  ];

  wsl.enable = true;
  wsl.defaultUser = "cyril";

  system.stateVersion = "24.05";
}
