{...}: {
  imports = [
    ./homelab-shares.nix
    ./mainUser.nix
    ./cachix/cachix.nix
  ];
}
