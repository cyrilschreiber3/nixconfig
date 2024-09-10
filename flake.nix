{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # plasma-manager = {
    #   url = "github:nix-community/plasma-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager.follows = "home-manager";
    # };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mypkgs = {
      url = "github:cyrilschreiber3/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    # plasma-manager,
    spicetify-nix,
    mypkgs,
    ...
  } @ inputs: {
    nixosConfigurations = {
      scorpius-cl-01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/scorpius-cl-01/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      scorpius-cl-01-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            wsl.enable = true;
          }
          ./hosts/scorpius-cl-01-wsl/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
    nixosModules = import "./modules/nixos/default.nix";
    homeManagerModules = import "./modules/home-manager/default.nix";
  };
}
