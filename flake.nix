{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # home-manager = {
    #   url = "github:nix-community/home-manager/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mypkgs = {
      url = "github:cyrilschreiber3/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    main-config = {
      url = "github:cyrilschreiber3/nixconfig/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mypkgs.follows = "mypkgs";
      inputs.ssh-keys.follows = "ssh-keys";
    };

    ssh-keys = {
      url = "https://github.com/cyrilschreiber3.keys";
      flake = false;
    };

    bar-sika = {
      url = "github:cyrilschreiber3/bar-sika";
      # url = "git+file:///home/cyril/Documents/dev/bar-sika";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    nixos-generators,
    mypkgs,
    main-config,
    ssh-keys,
    bar-sika,
    ...
  } @ inputs: {
    nixosConfigurations = {
      raspi-sika = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/raspi-sika/default.nix
          # inputs.home-manager.nixosModules.default
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
    };
    packages.aarch64-linux = {
      raspi-sika-sd = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/raspi-sika/default.nix
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
    };
  };
}
