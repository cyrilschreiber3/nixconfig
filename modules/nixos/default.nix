{...}: {
  imports = [
    ./autofs.nix
    ./games.nix
    ./mainUser.nix
    ./printers.nix
    ./vgpu.nix
    ./wireguard-client.nix
    ./x11vnc.nix
    ./cachix/cachix.nix
  ];
}
