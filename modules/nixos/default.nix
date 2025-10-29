{...}: {
  imports = [
    ./autofs.nix
    ./games.nix
    ./mainUser.nix
    ./printers.nix
    ./vgpu.nix
    ./wayland.nix
    ./wireguard-client.nix
    ./x11vnc.nix
    ./xserver.nix
    ./cachix/cachix.nix
  ];
}
