{
  description = "Nixos config flake";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mypkgs = {
      url = "github:cyrilschreiber3/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nixpkgs-stable,
    vgpu4nixos,
    ...
  } @ inputs: {
    nixosConfigurations = {
      scorpius-cl-01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          pkgs-stable = import nixpkgs-stable {
            system = "x86_64-linux";
            config = {
              allowUnfree = true;
            };
          };
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
    nixosModules = {
      mainUser = import ./modules/nixos/mainUser.nix;
      cachix = import ./modules/nixos/cachix/cachix.nix;
    };
    homeManagerModules = {
      btop = import ./modules/home-manager/btop.nix;
      cinnamon = import ./modules/home-manager/cinnamon.nix;
      firefox = import ./modules/home-manager/firefox.nix;
      git = import ./modules/home-manager/git.nix;
      gnome = import ./modules/home-manager/gnome.nix;
      spotify = import ./modules/home-manager/spotify.nix;
      vscode = import ./modules/home-manager/vscode.nix;
      zsh = import ./modules/home-manager/zsh.nix;
    };
  };
}
