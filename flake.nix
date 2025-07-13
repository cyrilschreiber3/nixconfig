{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-2405.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vgpu4nixos.url = "github:mrzenc/vgpu4nixos";
    fastapi-dls-nixos = {
      url = "github:mrzenc/fastapi-dls-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mypkgs = {
      url = "github:cyrilschreiber3/nur-packages";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    ssh-keys = {
      url = "https://github.com/cyrilschreiber3.keys";
      flake = false;
    };
  };

  outputs = {
    self,
    disko,
    home-manager,
    nixos-hardware,
    nixos-wsl,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    nixosConfigurations = {
      scorpius-cl-01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          disko.nixosModules.disko
          # nixos-hardware.nixosModules.lenovo-legion-16irx8h
          home-manager.nixosModules.default
          ./hosts/scorpius-cl-01/configuration.nix
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
          home-manager.nixosModules.default
        ];
      };
    };
    overlays = import ./overlays/default.nix {
      inherit inputs;
    };
    nixosModules = {
      default = import ./modules/nixos/default.nix;
    };
    homeManagerModules = {
      default = import ./modules/home-manager/default.nix;
    };
    packages = {
      myOMPConfig = import ./modules/dotfiles/omp/oh-my-posh-config.nix;
    };
  };
}
