{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # home-manager = {
    #   url = "github:nix-community/home-manager/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    mypkgs = {
      url = "github:cyrilschreiber3/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    main-config = {
      url = "github:cyrilschreiber3/nixconfig/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mypkgs.follows = "mypkgs";
    };

    ssh-keys = {
      url = "https://github.com/cyrilschreiber3.keys";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    mypkgs,
    main-config,
    ssh-keys,
    ...
  } @ inputs: {
    nixosConfigurations = {
      raspi-sika = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
          ./hosts/raspi-sika/configuration.nix
          # inputs.home-manager.nixosModules.default
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
    };
  };
}
