{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mypkgs = {
      url = "github:cyrilschreiber3/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    main-config = {
      url = "github:cyrilschreiber3/nixconfig/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    mypkgs,
    main-config,
    ...
  } @ inputs: {
    nixosConfigurations = {
      aquila-vpn-01 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/aquila-vpn-01/configuration.nix
          inputs.home-manager.nixosModules.default
          nixos-hardware.nixosModules.raspberry-pi-3
        ];
      };
    };
  };
}
