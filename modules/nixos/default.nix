{...}: {
  imports = [
    ./autofs.nix
    ./games.nix
    ./mainUser.nix
    ./printers.nix
    ./sops.nix
    ./vgpu.nix
    ./wayland.nix
    ./wireguard-client.nix
    ./wireguard-tunnels.nix
    ./x11vnc.nix
    ./xserver.nix
    ./cachix/cachix.nix
  ];
}
